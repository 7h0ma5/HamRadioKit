//
//  Conditions.swift
//  QLog (macOS)
//
//  Created by Thomas Gatzweiler on 16.05.22.
//

import Foundation

public struct Conditions {
    public let flux: Int
    public let kIndex: Double
    
    static let fluxUrl: URL = URL(string: "https://services.swpc.noaa.gov/products/summary/10cm-flux.json")!
    static let kIndexUrl: URL = URL(string: "https://services.swpc.noaa.gov/products/noaa-planetary-k-index.json")!
    
    public static func get() async throws -> Conditions {
        let flux = try await self.requestFlux()
        let kIndex = try await self.requestKIndex()
        return Conditions(flux: flux, kIndex: kIndex)
    }
    
    static func requestFlux() async throws -> Int {
        let (data, _response) = try await URLSession.shared.data(from: fluxUrl);
        let decoder = JSONDecoder()
        let obj = try! decoder.decode(Dictionary<String, String>.self, from: data)
        return Int(obj["Flux"]!)!
    }
    
    static func requestKIndex() async throws -> Double {
        let (data, _response) = try await URLSession.shared.data(from: kIndexUrl);
        let decoder = JSONDecoder()
        let obj = try! decoder.decode([[String]].self, from: data)
        return Double(obj.last![2])!
        
    }
}

