//
//  CountryData.swift
//  
//
//  Created by Thomas Gatzweiler on 21.08.22.
//

import Foundation
import Logging
import BinaryCodable

public struct CountryData: Equatable, Codable {
    public let timestamp: Date
    public let entities: [DXCC: CountryEntity]
    public let prefixes: [String: [CountryEntity.Prefix]]

    private static let logger = Logger(
        label: String(describing: CountryData.self)
    )

    private static var fileURL: URL? = {
        guard var path = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { return nil }

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

            path.appendPathComponent("country.dat")

            return path
        }
        catch {
            return nil
        }
    }()

    public static func load(path: URL? = nil) -> CountryData {
        guard let url = (path != nil ? path : Self.fileURL) else { return CountryData() }

        Self.logger.info("Trying to load country data from \(url.description)")

        guard let binaryData = try? Data(contentsOf: url) else {
            return CountryData()
        }

        guard let data = try? BinaryDecoder().decode(CountryData.self, from: binaryData) else {
            return CountryData()
        }

        return data
    }

    public func store(path: URL? = nil) {
        guard let url = (path != nil ? path : Self.fileURL) else { return }

        if let encodedData = try? BinaryEncoder().encode(self) {
            do {
                try encodedData.write(to: url)
                Self.logger.info("Country file update complete!")
            }
            catch {
                Self.logger.error("Failed to write country file!")
            }
        }
    }

    public func update() {
        if timestamp.addingTimeInterval(7*24*60*60) > Date() {
            Self.logger.info("Country file up to date")
            return
        }
        else {
            Self.logger.info("Country file OUT of date")
        }
    }

    public func lookup(byId id: DXCC) -> CountryEntity? {
        self.entities[id]
    }

    public func lookup(callsign: String, date: Date = Date()) -> CountryEntity? {
        guard callsign.count > 0 else { return nil }

        if let result = lookup(prefix: callsign, date: date, exact: true),
           let entity = self.lookup(byId: result.entityId) {
            return CountryEntity(merge: entity, with: result)
        }

        for idx in (1...callsign.count).reversed() {
            let prefix = String(callsign.prefix(idx))

            if let result = lookup(prefix: callsign, date: date, exact: false),
               let entity = self.lookup(byId: result.entityId) {
                return CountryEntity(merge: entity, with: result)
            }
        }

        return nil
    }

    public func lookup(prefix: String, date: Date = Date(), exact: Bool = false) -> CountryEntity.Prefix? {
        let candidates = prefixes[prefix] ?? []

        for candidate in candidates {
            if exact && !candidate.exact { continue }
            if let start = candidate.start, start > date { continue }
            if let end = candidate.end, end < date { continue }

            return candidate
        }

        return nil
    }

    public func merge(with other: CountryData) -> CountryData {
        let entityList = other.entities.map { (_, otherEntity) in
            if let entity = self.lookup(byId: otherEntity.id) {
                return (entity.id, CountryEntity(merge: entity, with: otherEntity))
            }
            else { return (otherEntity.id, otherEntity) }
        }

        let entities = Dictionary(uniqueKeysWithValues: entityList)

        let prefixList = other.prefixes.flatMap { (prefixString, prefixList) in
            return prefixList.map { otherPrefix in
                for thisPrefix in self.prefixes[prefixString] ?? [] {
                    guard !otherPrefix.exact || (otherPrefix.exact && thisPrefix.exact)
                    else { continue }

                    // TODO: check date range

                    let mergedPrefix = CountryEntity.Prefix(merge: thisPrefix, with: otherPrefix)

                    guard let entity = entities[mergedPrefix.entityId] else { continue }
                    return CountryEntity.Prefix(of: entity, mergedPrefix)
                }

                return otherPrefix
            }
        }

        let prefixes = Dictionary.init(grouping: prefixList, by: { $0.prefix })

        return CountryData(
            timestamp: other.timestamp,
            entities: entities,
            prefixes: prefixes
        )
    }
}

extension CountryData {
    private init() {
        self.timestamp = Date()
        self.entities = [:]
        self.prefixes = [:]
    }
}

public struct CountryEntity: Equatable, Codable {
    public let id: DXCC
    public let prefix: String
    public let name: String
    public let cont: String
    public let cqz: UInt8?
    public let ituz: UInt8?
    public let lat: Float?
    public let lon: Float?
    public let tz: Float?
    public let deleted: Bool
    public let start: Date?
    public let end: Date?

    enum CodingKeys: Int, CodingKey {
        case id = 1
        case prefix = 2
        case name = 3
        case cont = 4
        case cqz = 5
        case ituz = 6
        case lat = 7
        case lon = 8
        case tz = 9
        case deleted = 10
        case start = 11
        case end = 12
    }

    public struct Prefix: Equatable, Codable {
        public let prefix: String
        public let exact: Bool
        public let entityId: DXCC
        public let cont: String?
        public let cqz: UInt8?
        public let ituz: UInt8?
        public let lat: Float?
        public let lon: Float?
        public let tz: Float?
        public let start: Date?
        public let end: Date?

        enum CodingKeys: Int, CodingKey {
            case prefix = 1
            case exact = 2
            case entityId = 3
            case cont = 4
            case cqz = 5
            case ituz = 6
            case lat = 7
            case lon = 8
            case tz = 9
            case start = 10
            case end = 11
        }
    }
}

extension CountryEntity {
    /// Merge two CountryEntities. The other CountryEntity takes precendence above the base CountryEntity.
    public init(merge base: CountryEntity, with other: CountryEntity) {
        self.id = other.id
        self.prefix = other.prefix
        self.name = other.name
        self.cont = other.cont
        self.cqz = other.cqz ?? base.cqz
        self.ituz = other.ituz ?? base.ituz
        self.lat = other.lat ?? base.lat
        self.lon = other.lon ?? base.lon
        self.tz = other.tz ?? base.tz
        self.deleted = other.deleted
        self.start = other.start ?? base.start
        self.end = other.start ?? base.end
    }

    /// Merge a CountryEntity with a Prefix. Values set in the Prefix take precendence.
    public init(merge base: CountryEntity, with prefix: Prefix) {
        self.id = base.id
        self.prefix = prefix.prefix
        self.name = base.name
        self.cont = prefix.cont ?? base.cont
        self.cqz = prefix.cqz ?? base.cqz
        self.ituz = prefix.ituz ?? base.ituz
        self.lat = prefix.lat ?? base.lat
        self.lon = prefix.lon ?? base.lon
        self.tz = prefix.tz ?? base.tz
        self.deleted = base.deleted
        self.start = prefix.start ?? base.start
        self.end = prefix.end ?? base.end
    }
}

extension CountryEntity.Prefix {
    /// Create a new Prefix for a CountryEntity with only the fields set that differ from that CountryEntity
    public init(of base: CountryEntity, _ prefix: CountryEntity.Prefix) {
        self.exact = prefix.exact
        self.entityId = base.id
        self.prefix = prefix.prefix
        self.cont = prefix.cont != base.cont ? prefix.cont : nil
        self.cqz = prefix.cqz != base.cqz ? prefix.cqz : nil
        self.ituz = prefix.ituz != base.ituz ? prefix.ituz : nil
        self.lat = prefix.lat != base.lat ? prefix.lat : nil
        self.lon = prefix.lon != base.lon ? prefix.lon : nil
        self.tz = prefix.tz != base.tz ? prefix.tz : nil
        self.start = prefix.start
        self.end = prefix.end
    }

    /// Merge two Prefixes. The other Prefix takes precendence above the base Prefix.
    public init(merge base: CountryEntity.Prefix, with other: CountryEntity.Prefix)  {
        self.prefix = other.prefix
        self.exact = other.exact
        self.entityId = other.entityId
        self.cont = other.cont ?? base.cont
        self.cqz = other.cqz ?? base.cqz
        self.ituz = other.ituz ?? base.ituz
        self.lat = other.lat ?? base.lat
        self.lon = other.lon ?? base.lon
        self.tz = other.tz ?? base.tz
        self.start = other.start
        self.end = other.end
    }
}
