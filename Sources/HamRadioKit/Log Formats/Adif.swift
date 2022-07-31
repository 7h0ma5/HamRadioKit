//
//  Adif.swift
//  QLog (iOS)
//
//  Created by Thomas Gatzweiler on 11.05.22.
//

import Foundation

private let adifDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")!
    return dateFormatter
}()

private let adifDateFormatterMinutes: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd HHmm"
    dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")!
    return dateFormatter
}()

private let adifDateFormatterSeconds: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd HHmmss"
    dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")!
    return dateFormatter
}()

private let adifTimeFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HHmmss"
    dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")!
    return dateFormatter
}()

private struct AdifContact {
    let fields: [AdifField]
}

private struct AdifHeader {
    let fields: [AdifField]
}

private struct AdifField {
    let name: Substring
    let value: Substring?
}

public class AdifReader {
    private var data: Substring
    private var header: AdifHeader?

    private var initialCount: Int

    static func parseDatetime(date: String, time: String?) -> Date? {
        if let time = time {
            if time.count == 4 {
                return adifDateFormatterMinutes.date(from: date + " " + time)
            }
            else if time.count == 6 {
                return adifDateFormatterSeconds.date(from: date + " " + time)
            }
            else {
                return adifDateFormatter.date(from: date)
            }
        }
        else {
            return adifDateFormatter.date(from: date)
        }
    }

    public init(data: Substring) {
        self.data = data
        self.initialCount = self.data.maximumLengthOfBytes(using: .utf8)
    }

    public var progress: Double {
        1.0 - (Double(self.data.maximumLengthOfBytes(using: .utf8)) / Double(self.initialCount))
    }

    private func readField() -> AdifField? {
        data = data.drop(while: { $0 != "<" }).dropFirst()

        if data.isEmpty { return nil }

        let name = data.prefix(while: { $0 != ":" && $0 != ">" })
        data = data.dropFirst(name.count)

        if data.isEmpty { return nil }

        if data.popFirst() == ">" {
            return AdifField(name: name, value: nil)
        }

        let size = data.prefix(while: { $0 != ":" && $0 != ">" })
        data = data.dropFirst(size.count)

        if data.isEmpty { return nil }

        if data.popFirst() == ":" {
            let dataType = data.prefix(while: { $0 != ">" })
            data = data.dropFirst(dataType.count + 1)
        }

        if data.isEmpty { return nil }

        let length = Int(size) ?? 0
        if length == 0 || data.isEmpty { return nil }

        let value = data.prefix(length)
        data = data.dropFirst(length)

        return AdifField(name: name, value: value)
    }

    private func readHeader() {
        if data.starts(with: "<") {
            self.header = Optional.some(AdifHeader(fields: []))
            return
        }

        var fields: [AdifField] = []

        while let field = readField() {
            if field.name.lowercased() == "eoh" {
                header = AdifHeader(fields: fields)
                return
            }
            fields.append(field)
        }
    }

    private func readContact() -> AdifContact? {
        if self.header == nil {
            readHeader()
        }

        var fields: [AdifField] = []

        while let field = readField() {
            if field.name.lowercased() == "eor" {
                return AdifContact(fields: fields)
            }
            fields.append(field)
        }

        return nil
    }

    // TODO: Refactor this function
    // swiftlint:disable:next cyclomatic_complexity
    public func readEntry() -> LogEntry? {
        guard let contact = readContact() else { return nil }

        var entry = LogEntry()

        var startDate: String?
        var startTime: String?
        var endDate: String?
        var endTime: String?

        for field in contact.fields {
            guard let value = field.value else { continue }

            switch field.name.lowercased() {
            case "app_qlog_id": entry.id = UUID(uuidString: String(value)) ?? entry.id
            case "app_qlog_logbook": entry.logbookId = UUID(uuidString: String(value))
            case "qso_date": startDate = String(value)
            case "qso_date_off": endDate = String(value)
            case "time_on": startTime = String(value)
            case "time_off": endTime = String(value)
            case "call": entry.callsign = String(value)
            case "name": entry.name = String(value)
            case "qth": entry.qth = String(value)
            case "rst_rcvd": entry.rstRcvd = String(value)
            case "rst_sent": entry.rstSent = String(value)
            case "mode": entry.mode = Mode.find(byName: value.uppercased())
            case "submode": entry.submode = value.uppercased()
            case "freq": entry.freq = Frequency(fromMegaHertz: value)
            case "band": entry.band = Band.find(byName: value.lowercased())
            case "gridsquare": entry.gridsquare = value.uppercased()
            case "cqz": entry.cqz = UInt64(value)
            case "ituz": entry.ituz = UInt64(value)
            case "cont": entry.cont = value.uppercased()
            case "dxcc": entry.dxcc = UInt64(value)
            case "country": entry.country = String(value)
            case "pfx": entry.pfx = String(value)
            case "state": entry.state = String(value)
            case "cnty": entry.cnty = String(value)
            case "lat": entry.lat = Double(value)
            case "lon": entry.lon = Double(value)
            case "iota": entry.iota = value.uppercased()
            case "sota_ref": entry.sota = value.uppercased()
            case "qsl_rcvd": entry.qslRcvd = .init(rawValue: value.uppercased()) ?? .no
            case "qslrdate": entry.qslRdate = adifDateFormatter.date(from: String(value))
            case "qsl_sent": entry.qslSent = .init(rawValue: value.uppercased()) ?? .no
            case "qslsdate": entry.qslSdate = adifDateFormatter.date(from: String(value))
            case "qsl_via": entry.qslVia = String(value)
            case "lotw_qsl_rcvd": entry.lotwQslRcvd = .init(rawValue: value.uppercased()) ?? .no
            case "lotw_qslrdate": entry.lotwQslRdate = adifDateFormatter.date(from: String(value))
            case "lotw_qsl_sent": entry.lotwQslSent = .init(rawValue: value.uppercased()) ?? .no
            case "lotw_qslsdate": entry.lotwQslSdate = adifDateFormatter.date(from: String(value))
            case "tx_pwr": entry.txPwr = Double(value)
            case "comment": entry.comment = String(value)
            case "notes": entry.notes = String(value)
            case "my_antenna": entry.myAntenna = String(value)
            case "my_rig": entry.myRig = String(value)
            case "my_gridsquare": entry.myGridsquare = String(value)
            case "my_dxcc": entry.myDxcc = UInt64(value)
            case "my_lat": entry.myLat = Double(value)
            case "my_lon": entry.myLon = Double(value)
            case "my_iota": entry.myIota = String(value)
            case "my_sota_ref": entry.mySota = String(value)
            case "station_callsign": entry.stationCallsign = String(value)
            case "operator": entry.stationOperator = String(value)
            case "contest_id": entry.contestId = String(value)
            case "stx": entry.serialSent = String(value)
            case "srx": entry.serialRcvd = String(value)
            case "stx_string": entry.serialSent = String(value)
            case "srx_string": entry.serialRcvd = String(value)
            default:
                debugPrint("unknown field:", field.name)
            }
        }

        if let startDate = startDate,
           let start = Self.parseDatetime(date: startDate, time: startTime) {

            entry.startTime = start
            entry.endTime = start
        }

        if let endDate = endDate,
           let end = Self.parseDatetime(date: endDate, time: endTime) {

            entry.endTime = end
        }

        return entry
    }
}

public class AdifWriter {
    private(set) public var data: String = ""

    public init(withHeader: Bool) {
        if withHeader {
            writeHeader()
        }
    }

    func writeHeader() {
        data = "### QLog ADIF Export\n"
        write(field: "adif_ver", "3.1.3")

        if let programId = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            write(field: "programid", programId)
        }

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            write(field: "programversion", version)
        }

        write(field: "created_timestamp", adifDateFormatterSeconds.string(from: Date()))
        write(field: "eoh")
    }

    func write(field: String) {
        data += "<\(field)>\n\n"
    }

    func write(field: String, _ value: String) {
        data += "<\(field):\(value.count)>\(value)\n"
    }

    func write(field: String, _ value: String?) {
        if let value = value {
            write(field: field, value)
        }
    }

    func write(field: String, _ value: UInt64?) {
        if let value = value {
            write(field: field, String(value))
        }
    }

    func write(field: String, _ value: Double?) {
        if let value = value {
            write(field: field, String(value))
        }
    }

    public func write(entry: LogEntry) {
        write(field: "app_qlog_id", entry.id.uuidString)
        write(field: "app_qlog_logbook", entry.logbookId.map { $0.uuidString })

        write(field: "qso_date", adifDateFormatter.string(from: entry.startTime))
        write(field: "time_on", adifTimeFormatter.string(from: entry.startTime))

        write(field: "qso_date_off", adifDateFormatter.string(from: entry.endTime ?? entry.startTime))
        write(field: "time_off", adifTimeFormatter.string(from: entry.endTime ?? entry.startTime))

        write(field: "call", entry.callsign)
        write(field: "qth", entry.qth)
        write(field: "name", entry.name)
        write(field: "freq", entry.freq.map { Double($0)/1e6 })
        write(field: "band", entry.band?.rawValue)
        write(field: "mode", entry.mode?.rawValue)
        write(field: "submode", entry.submode)
        write(field: "gridsquare", entry.gridsquare)
        write(field: "rst_sent", entry.rstSent)
        write(field: "rst_rcvd", entry.rstRcvd)
        write(field: "dxcc", entry.dxcc)
        write(field: "cqz", entry.cqz)
        write(field: "ituz", entry.ituz)
        write(field: "cont", entry.cont)
        write(field: "country", entry.country)
        write(field: "pfx", entry.pfx)
        write(field: "state", entry.state)
        write(field: "cnty", entry.cnty)
        write(field: "lat", entry.lat)
        write(field: "lon", entry.lon)
        write(field: "iota", entry.iota)
        write(field: "sota", entry.sota)
        write(field: "qsl_rcvd", entry.qslRcvd.rawValue)
        write(field: "qsl_rdate", entry.qslRdate.map { adifDateFormatter.string(from: $0) })
        write(field: "qsl_sent", entry.qslSent.rawValue)
        write(field: "qsl_sdate", entry.qslSdate.map { adifDateFormatter.string(from: $0) })
        write(field: "qsl_via", entry.qslVia)
        write(field: "lotw_qsl_rcvd", entry.lotwQslRcvd.rawValue)
        write(field: "lotw_qslrdate", entry.lotwQslRdate.map { adifDateFormatter.string(from: $0) })
        write(field: "lotw_qsl_sent", entry.lotwQslSent.rawValue)
        write(field: "lotw_qslsdate", entry.lotwQslSdate.map { adifDateFormatter.string(from: $0) })
        write(field: "tx_pwr", entry.txPwr)
        write(field: "comment", entry.comment)
        write(field: "notes", entry.notes)
        write(field: "my_antenna", entry.myAntenna)
        write(field: "my_rig", entry.myRig)
        write(field: "my_gridsquare", entry.myGridsquare)
        write(field: "my_dxcc", entry.myDxcc)
        write(field: "my_lat", entry.myLat)
        write(field: "my_lon", entry.myLon)
        write(field: "my_iota", entry.myIota)
        write(field: "my_sota", entry.mySota)
        write(field: "station_callsign", entry.stationCallsign)
        write(field: "operator", entry.stationOperator)
        write(field: "contest_id", entry.contestId)
        write(field: "stx", entry.serialSent)
        write(field: "srx", entry.serialRcvd)
        write(field: "eor")
    }

    public func write(entries: [LogEntry]) {
        entries.forEach(self.write(entry:))
    }
}
