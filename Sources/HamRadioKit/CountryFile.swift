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

public class CountryFile {
    static let url: URL = URL(string: "https://www.country-files.com/cty/cty.csv")!

    private static let logger = Logger(
        label: String(describing: CountryFile.self)
    )

    public init() {
        
    }

    public func download() async throws -> CountryData {
        // URLSession.shared.data is not yet implemented in FoundationNetworking
        #if canImport(FoundationNetworking)
        let rawData: Data? = await withCheckedContinuation { continuation in
            URLSession.shared.dataTask(with: Self.url) { data, _, _ in
                continuation.resume(returning: data)
            }.resume()
        }

        guard let rawData = rawData else { throw DownloadError() }
        #else
        let (rawData, response) = try await URLSession.shared.data(from: Self.url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else
        {
            Self.logger.warning("Failed to download country file")
            throw DownloadError()
        }
        #endif

        let data = String(decoding: rawData, as: UTF8.self)

        var prefixList: [CountryEntity.Prefix] = []
        var entityMap: [DXCC: CountryEntity] = [:]

        let lines: [Substring] = data.split(whereSeparator: \.isNewline)

        lines.forEach { line in
            let fields: [Substring] = line.split(separator: ",")

            if fields.count != 10 {
                Self.logger.warning("Invalid line in country file")
                return
            }
            else if fields[0].starts(with: "*") {
                return
            }

            guard let dxccId = DXCC(fields[2]) else { return }

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

                prefixList.append(CountryEntity.Prefix(
                    prefix: String(pfxString),
                    exact: exact,
                    entityId: dxccId,
                    cont: nil,
                    cqz: cqzOverride.flatMap { UInt8($0) },
                    ituz: ituzOverride.flatMap { UInt8($0) },
                    lat: nil,
                    lon: nil,
                    tz: nil,
                    start: nil,
                    end: nil
                ))
            }

            entityMap[dxccId] = CountryEntity(
                id: dxccId,
                prefix: String(fields[0]),
                name: String(fields[1]),
                cont: String(fields[3]),
                cqz: UInt8(fields[4]),
                ituz: UInt8(fields[5]),
                lat: Float(fields[6]),
                lon: Float(fields[7]),
                tz: Float(fields[8]),
                deleted: false,
                start: nil,
                end: nil
            )
        }

        return CountryData(
            timestamp: Date(),
            entities: entityMap,
            prefixes: Dictionary.init(grouping: prefixList, by: { $0.prefix })
        )
    }
}
