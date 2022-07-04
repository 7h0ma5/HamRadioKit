//
//  HamQTH.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 19.05.22.
//

import Foundation
import SWXMLHash

public struct CallbookEntry {
    public let callsign: String
    public let name: String?
    public let qth: String?
    public let gridsquare: Locator?
    public let country: String?
    public let dxccId: Int64?
}

public class HamQTH {
    public static let shared = HamQTH()
    
    var sessionId: String?
    
    public func login() async -> String? {
        var urlComponents = URLComponents(string: "https://www.hamqth.com/xml.php")!
        urlComponents.queryItems = [
            URLQueryItem(name: "u", value: UserDefaults.standard.string(forKey: "hamqth.username")),
            URLQueryItem(name: "p", value: UserDefaults.standard.string(forKey: "hamqth.password"))
        ]
        let url = urlComponents.url!;
        
        let (rawData, _response) = try! await URLSession.shared.data(from: url)
        let xml = XMLHash.parse(rawData)
        
        return xml["HamQTH"]["session"]["session_id"].element?.text
    }
    
    public func lookup(callsign: String) async -> CallbookEntry? {
        if sessionId == nil {
            sessionId = await login()
        }
        
        var urlComponents = URLComponents(string: "https://www.hamqth.com/xml.php")!
        urlComponents.queryItems = [
            URLQueryItem(name: "id", value: sessionId),
            URLQueryItem(name: "callsign", value: callsign),
            URLQueryItem(name: "prg", value: "QLog")
        ]
        let url = urlComponents.url!;
        
        let (rawData, _response) = try! await URLSession.shared.data(from: url)
        let xml = XMLHash.parse(rawData)
        
        let result = xml["HamQTH"]["search"]
        
        debugPrint(result)
        
        return CallbookEntry(
            callsign: callsign,
            name: result["nick"].element?.text,
            qth: result["qth"].element?.text,
            gridsquare: result["grid"].element?.text,
            country: result["country"].element?.text,
            dxccId: (result["adif"].element?.text).flatMap(Int64.init)
        )
    }
}
