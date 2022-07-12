//
//  CountryFile.swift
//  QLog (iOS)
//
//  Created by Thomas Gatzweiler on 18.05.22.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Logging

struct CountryData: Equatable, Codable {
    let timestamp: Date
    let entities: [DXCC: CountryEntity]
    let prefixes: [String: CountryPrefix]
}

public struct CountryEntity: Equatable, Codable {
    public let id: DXCC
    public let prefix: String
    public let name: String
    public let cont: String
    public let cqz: UInt64
    public let ituz: UInt64
    public let lat: Double
    public let lon: Double
    public let tz: Double

    func mergeWith(prefix: CountryPrefix) -> CountryEntity {
        CountryEntity(
            id: self.id,
            prefix: self.prefix,
            name: self.name,
            cont: self.cont,
            cqz: prefix.cqz ?? self.cqz,
            ituz: prefix.ituz ?? self.ituz,
            lat: self.lat,
            lon: self.lon,
            tz: self.tz
        )
    }
}

struct CountryPrefix: Equatable, Codable {
    let prefix: String
    let exact: Bool
    let entityId: DXCC
    let cqz: UInt64?
    let ituz: UInt64?
}

public class CountryFile {
    static let url: URL = URL(string: "https://www.country-files.com/cty/cty.csv")!
    public static let shared = CountryFile()

    var fileURL: URL?
    var data: CountryData?

    private static let logger = Logger(
        label: String(describing: CountryFile.self)
    )

    init() {
        guard var path = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { return }

        if let bundleId = Bundle.main.bundleIdentifier {
            path.appendPathComponent(bundleId)
        }
        else {
            path.appendPathComponent("HamRadioKit")
        }

        do {
            try FileManager.default.createDirectory(
                atPath: path.path,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        catch {
            return
        }

        path.appendPathComponent("country.json")

        self.fileURL = path

        Self.logger.info("Trying to load country data from \(path.description)")

        guard let jsonData = try? Data(contentsOf: path) else {
            return
        }

        guard let data = try? JSONDecoder().decode(CountryData.self, from: jsonData) else {
            return
        }

        self.data = data
    }

    public func lookup(byId id: UInt64) -> CountryEntity? {
        self.data?.entities[id]
    }

    public func lookup(callsign: String) -> CountryEntity? {
        guard callsign.count > 0 else { return nil }

        guard let prefixes = data?.prefixes else {
            return nil
        }

        if let exactPrefix = prefixes[callsign],
           exactPrefix.exact == true,
           let entity = self.lookup(byId: exactPrefix.entityId)
        {
            return entity.mergeWith(prefix: exactPrefix)
        }

        for idx in (1...callsign.count).reversed() {
            let prefix = String(callsign.prefix(idx))

            if let prefixResult = prefixes[prefix], prefixResult.exact == false,
               let entity = self.lookup(byId: prefixResult.entityId)
            {
                return entity.mergeWith(prefix: prefixResult)
            }
        }

        return nil
    }

    public func update() async throws {
        if let lastUpdate = self.data?.timestamp {
            if lastUpdate.addingTimeInterval(7*24*60*60) > Date() {
                Self.logger.info("Country file up to date")
                return
            }
            else {
                Self.logger.info("Country file OUT of date")
            }
        }
        else {
            Self.logger.info("Initial country file update")
        }

        // URLSession.shared.data is not yet implemented in FoundationNetworking
        #if canImport(FoundationNetworking)
        let rawData: Data? = await withCheckedContinuation { continuation in
            URLSession.shared.dataTask(with: Self.url) { data, _, _ in
                continuation.resume(returning: data)
            }.resume()
        }

        guard let rawData = rawData else { return }
        #else
        let (rawData, response) = try await URLSession.shared.data(from: Self.url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else
        {
            Self.logger.warning("Failed to download country file")
            return
        }
        #endif

        let data = String(decoding: rawData, as: UTF8.self)[...]

        var prefixMap: [String: CountryPrefix] = [:]
        var entityMap: [DXCC: CountryEntity] = [:]

        data.split(whereSeparator: \.isNewline).forEach { line in
            let fields = line.split(separator: ",")

            if fields.count != 10 {
                Self.logger.warning("Invalid line in country file")
                return
            }
            else if fields[0].starts(with: "*") {
                return
            }

            guard let dxccId = UInt64(fields[2]) else { return }

            let prefixes = fields[9].split(separator: " ")

            prefixes.forEach { pfxException in
                var pfx = pfxException

                if pfx.isEmpty { return }

                var exact = false

                if pfx.starts(with: "=") {
                    exact = true
                    pfx = pfx.dropFirst()
                }

                let pfxString = pfx.prefix(while: { $0 != "[" && $0 != "(" && $0 != ";"})
                pfx = pfx.dropFirst(pfxString.count)

                var cqzOverride: Substring?
                var ituzOverride: Substring?

                while !pfx.isEmpty {
                    switch pfx.popFirst() {
                    case "(":
                        cqzOverride = pfx.prefix(while: { $0 != ")" })
                        pfx = pfx.dropFirst((cqzOverride?.count ?? 0) + 1)

                    case "[":
                        ituzOverride = pfx.prefix(while: { $0 != "]" })
                        pfx = pfx.dropFirst((ituzOverride?.count ?? 0) + 1)

                    case ";":
                        pfx = pfx.dropFirst()

                    default:
                        Self.logger.warning("Unexpected character in country file")
                    }
                }

                let prefix = String(pfxString)

                prefixMap[prefix] = CountryPrefix(
                    prefix: prefix,
                    exact: exact,
                    entityId: dxccId,
                    cqz: cqzOverride.flatMap { UInt64($0) },
                    ituz: ituzOverride.flatMap { UInt64($0) }
                )
            }

            entityMap[dxccId] = CountryEntity(
                id: dxccId,
                prefix: String(fields[0]),
                name: String(fields[1]),
                cont: String(fields[3]),
                cqz: UInt64(fields[4])!,
                ituz: UInt64(fields[5])!,
                lat: Double(fields[6])!,
                lon: Double(fields[7])!,
                tz: Double(fields[8])!
            )
        }

        self.data = CountryData(
            timestamp: Date(),
            entities: entityMap,
            prefixes: prefixMap
        )

        if let encodedData = try? JSONEncoder().encode(self.data), let url = fileURL {
            do {
                try encodedData.write(to: url)
                Self.logger.info("Country file update complete!")
            }
            catch {
                Self.logger.error("Failed to write country file!")
            }
        }
    }
}
