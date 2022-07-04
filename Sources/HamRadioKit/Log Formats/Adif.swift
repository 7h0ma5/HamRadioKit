//
//  Adif.swift
//  QLog (iOS)
//
//  Created by Thomas Gatzweiler on 11.05.22.
//

import Foundation
import UniformTypeIdentifiers

fileprivate let AdifDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")!
    return dateFormatter
}()

fileprivate let AdifDateFormatterMinutes: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd HHmm"
    dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")!
    return dateFormatter
}()

fileprivate let AdifDateFormatterSeconds: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd HHmmss"
    dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")!
    return dateFormatter
}()

fileprivate let AdifTimeFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HHmmss"
    dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")!
    return dateFormatter
}()


fileprivate struct AdifContact {
    let fields: [AdifField]
}

fileprivate struct AdifHeader {
    let fields: [AdifField]
}

fileprivate struct AdifField {
    let name: Substring
    let value: Substring?
}

public class AdifReader {
    fileprivate var data: Substring
    fileprivate var header: Optional<AdifHeader> = nil
    
    fileprivate var initialCount: Int
    
    static func parseDatetime(date: String, time: String?) -> Date? {
        if let time = time {
            if time.count == 4 {
                return AdifDateFormatterMinutes.date(from: date + " " + time)
            }
            else if time.count == 6 {
                return AdifDateFormatterSeconds.date(from: date + " " + time)
            }
            else {
                return AdifDateFormatter.date(from: date)
            }
        }
        else {
            return AdifDateFormatter.date(from: date)
        }
    }
    
    public init(data: Substring) {
        self.data = data
        self.initialCount = data.count
    }
    
    public var progress: Double {
        (Double(initialCount) / Double(data.count)) - 1.0
    }
    
    private func readField() -> AdifField? {
        data = data.drop(while: { $0 != "<" }).dropFirst()
        
        if data.isEmpty { return nil }
        
        let name = data.prefix(while: { $0 != ":" && $0 != ">" })
        data = data.dropFirst(name.count)
        
        if data.isEmpty { return nil }
        
        if data.popFirst() == ">" {
            return AdifField(name: name, value: nil);
        }
        
        let size = data.prefix(while: { $0 != ":" && $0 != ">" })
        data = data.dropFirst(size.count)
        
        if data.isEmpty { return nil }
        
        if data.popFirst() == ":" {
            let dataType = data.prefix(while: { $0 != ">" })
            data = data.dropFirst(dataType.count + 1)
        }
        
        if data.isEmpty { return nil }
        
        let length = Int(size) ?? 0;
        if length == 0 || data.isEmpty { return nil }

        let value = data.prefix(length);
        data = data.dropFirst(length);
        
        return AdifField(name: name, value: value);
    }
    
    private func readHeader() {
        if data.starts(with: "<") {
            self.header = Optional.some(AdifHeader(fields: []));
            return;
        }
        
        var fields: [AdifField] = [];
        
        while let field = readField() {
            if (field.name.lowercased() == "eoh") {
                header = AdifHeader(fields: fields);
                return;
            }
            fields.append(field);
        }
    }
    
    private func readContact() -> AdifContact? {
        if self.header == nil {
            readHeader();
        }
        
        var fields: [AdifField] = [];
        
        while let field = readField() {
            if (field.name.lowercased() == "eor") {
                return AdifContact(fields: fields);
            }
            fields.append(field);
        }
        
        return nil;
    }
    
    public func readEntry() -> LogEntry? {
        guard let contact = readContact() else { return nil }
        
        var entry = LogEntry()
        
        var startDate: String? = nil
        var startTime: String? = nil
        var endDate: String? = nil
        var endTime: String? = nil
       
        for field in contact.fields {
            guard field.value != nil else { continue }
            
            let value = field.value!
            
            switch field.name.lowercased() {
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
            case "qslrdate": entry.qslRdate = AdifDateFormatter.date(from: String(value))
            case "qsl_sent": entry.qslSent = .init(rawValue: value.uppercased()) ?? .no
            case "qslsdate": entry.qslSdate = AdifDateFormatter.date(from: String(value))
            case "qsl_via": entry.qslVia = String(value)
            case "lotw_qsl_rcvd": entry.lotwQslRcvd = .init(rawValue: value.uppercased()) ?? .no
            case "lotw_qslrdate": entry.lotwQslRdate = AdifDateFormatter.date(from: String(value))
            case "lotw_qsl_sent": entry.lotwQslSent = .init(rawValue: value.uppercased()) ?? .no
            case "lotw_qslsdate": entry.lotwQslSdate = AdifDateFormatter.date(from: String(value))
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
                break;
            }
        }
        
        if let startDate = startDate {
            if let start = Self.parseDatetime(date: startDate, time: startTime) {
                entry.startTime = start
            }
            if let end = Self.parseDatetime(date: endDate ?? startDate, time: endTime ?? startTime) {
                entry.endTime = end
            }
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
        write(field: "ADIF_VER", "3.1.3")
        write(field: "PROGRAMID", "QLog")
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            write(field: "PROGRAMVERSION", version)
        }
    
        write(field: "CREATED_TIMESTAMP", AdifDateFormatterSeconds.string(from: Date()))
        write(field: "EOH")
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
    
    public func write(entry: LogEntry) {
        write(field: "call", entry.callsign)
        write(field: "qth", entry.qth)
        write(field: "name", entry.name)
        write(field: "freq", entry.freq)
        write(field: "band", entry.band?.rawValue)
        write(field: "mode", entry.mode?.rawValue)
        write(field: "gridsquare", entry.gridsquare)
        write(field: "dxcc", entry.dxcc)
        
        write(field: "qso_date", AdifDateFormatter.string(from: entry.startTime))
        write(field: "time", AdifTimeFormatter.string(from: entry.startTime))
        
        write(field: "qso_date_off", AdifDateFormatter.string(from: entry.endTime ?? entry.startTime))
        write(field: "time_off", AdifTimeFormatter.string(from: entry.endTime ?? entry.startTime))
        
        write(field: "eor")
    }
    
    public func write(entries: [LogEntry]) {
        entries.forEach(self.write(entry:))
    }
}
