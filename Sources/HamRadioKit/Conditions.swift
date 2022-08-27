//
//  Conditions.swift
//  QLog (macOS)
//
//  Created by Thomas Gatzweiler on 16.05.22.
//

import Foundation

@available(macOS 10.15, *)
public struct Conditions {
    /// Solar flux index.
    public let flux: Int
    /// Estimated planetary K-index.
    public let kIndex: Double

    static let fluxUrl: URL = URL(string: "https://services.swpc.noaa.gov/products/summary/10cm-flux.json")!
    static let kIndexUrl: URL = URL(string: "https://services.swpc.noaa.gov/products/noaa-planetary-k-index.json")!
    
    /// Fetch the current Conditions from NOAA.
    public static func get() async -> Result<Conditions, Error> {
        do {
            let flux = try await self.requestFlux()
            let kIndex = try await self.requestKIndex()
            return .success(Conditions(flux: flux, kIndex: kIndex))
        }
        catch let error as NSError {
            return .failure(error)
        }
    }

    static func requestFlux() async throws -> Int {
        let (data, _) = try await URLSession.shared.data(from: fluxUrl)

        let decoder = JSONDecoder()
        let obj = try decoder.decode([String: String].self, from: data)

        return Int(obj["Flux"]!)!
    }

    static func requestKIndex() async throws -> Double {
        let (data, _) = try await URLSession.shared.data(from: kIndexUrl)

        let decoder = JSONDecoder()
        let obj = try decoder.decode([[String]].self, from: data)
        return Double(obj.last![2])!
    }
}
