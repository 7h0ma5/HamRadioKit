//
//  File.swift
//  
//
//  Created by Thomas Gatzweiler on 19.08.22.
//

import Foundation
import Logging
import Gzip
import SWXMLHash
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Clublog {
    private let url: URL

    private static let logger = Logger(
        label: String(describing: Clublog.self)
    )

    public init(apiKey: String) {
        var urlComponents = URLComponents(string: "https://cdn.clublog.org/cty.php")!

        urlComponents.queryItems = [
            URLQueryItem(name: "api", value: apiKey)
        ]

        url = urlComponents.url!
    }

    public func download() async throws -> CountryData {
        let (rawData, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else
        {
            Self.logger.warning("Failed to download country file")
            throw DownloadError()
        }

        let xml = XMLHash.parse(try rawData.gunzipped())

        var entities: [DXCC: CountryEntity] = [:]
        var prefixes: [CountryEntity.Prefix] = []

        for entityData in xml["clublog"]["entities"].children {
            guard let id = (entityData["adif"].element?.text).flatMap(DXCC.init) else { continue }
            guard let prefix = entityData["prefix"].element?.text else { continue }
            guard let name = entityData["name"].element?.text else { continue }
            guard let cont = entityData["cont"].element?.text else { continue }

            let entity = CountryEntity(
                id: id,
                prefix: prefix,
                name: name,
                cont: cont,
                cqz: (entityData["cqz"].element?.text).flatMap(UInt8.init),
                ituz: (entityData["ituz"].element?.text).flatMap(UInt8.init),
                lat: (entityData["lat"].element?.text).flatMap(Float.init),
                lon: (entityData["long"].element?.text).flatMap(Float.init),
                tz: nil,
                deleted: entityData["deleted"].element?.text == "TRUE",
                start: (entityData["start"].element?.text).flatMap { try? Date($0, strategy: .iso8601) },
                end: (entityData["end"].element?.text).flatMap { try? Date($0, strategy: .iso8601) }
            )

            entities[id] = entity
        }

        for exceptionData in xml["clublog"]["exceptions"].children {
            guard let prefix = exceptionData["call"].element?.text else { continue }
            guard let id = (exceptionData["adif"].element?.text).flatMap(DXCC.init) else { continue }

            let prefixObj = CountryEntity.Prefix(
                prefix: prefix,
                exact: true,
                entityId: id,
                cont: exceptionData["cont"].element?.text,
                cqz: (exceptionData["cqz"].element?.text).flatMap(UInt8.init),
                ituz: (exceptionData["ituz"].element?.text).flatMap(UInt8.init),
                lat: (exceptionData["lat"].element?.text).flatMap(Float.init),
                lon: (exceptionData["long"].element?.text).flatMap(Float.init),
                tz: nil,
                start: (exceptionData["start"].element?.text).flatMap { try? Date($0, strategy: .iso8601) },
                end: (exceptionData["end"].element?.text).flatMap { try? Date($0, strategy: .iso8601) }
            )

            prefixes.append(prefixObj)
        }

        for prefixData in xml["clublog"]["prefixes"].children {
            guard let prefix = prefixData["call"].element?.text else { continue }
            guard let id = (prefixData["adif"].element?.text).flatMap(DXCC.init) else { continue }

            let prefixObj = CountryEntity.Prefix(
                prefix: prefix,
                exact: false,
                entityId: id,
                cont: prefixData["cont"].element?.text,
                cqz: (prefixData["cqz"].element?.text).flatMap(UInt8.init),
                ituz: (prefixData["ituz"].element?.text).flatMap(UInt8.init),
                lat: (prefixData["lat"].element?.text).flatMap(Float.init),
                lon: (prefixData["long"].element?.text).flatMap(Float.init),
                tz: nil,
                start: (prefixData["start"].element?.text).flatMap { try? Date($0, strategy: .iso8601) },
                end: (prefixData["end"].element?.text).flatMap { try? Date($0, strategy: .iso8601) }
            )

            prefixes.append(prefixObj)
        }

        let timestamp = xml["clublog"].value(ofAttribute: "date").flatMap { try? Date($0, strategy: .iso8601) }

        return CountryData(
            timestamp: timestamp ?? Date(),
            entities: entities,
            prefixes: Dictionary.init(grouping: prefixes, by: { $0.prefix })
        )
    }
}
