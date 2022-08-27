//
//  HamQTH.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 19.05.22.
//

import Foundation
import SWXMLHash

public struct HamQTHConfig {
    public var username: String = ""
    public var password: String = ""

    public init() {}
}

#if !os(Linux)
public class HamQTH: Callbook {
    public static let shared = HamQTH()
    public var config: HamQTHConfig = HamQTHConfig()

    private static let apiUrl = "https://www.hamqth.com/xml.php"
    private var sessionId: String?

    func login() async -> String? {
        guard !config.username.isEmpty && !config.password.isEmpty else {
            return nil
        }

        var urlComponents = URLComponents(string: Self.apiUrl)!

        urlComponents.queryItems = [
            URLQueryItem(name: "u", value: config.username),
            URLQueryItem(name: "p", value: config.password)
        ]

        guard let url = urlComponents.url else { return nil }

        guard let (rawData, response) = try? await URLSession.shared.data(from: url) else {
            return nil
        }

        guard let httpResponse = response as? HTTPURLResponse else { return nil }
        guard httpResponse.statusCode == 200 else { return nil }

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

        guard let url = urlComponents.url else { return nil }

        guard let (rawData, response) = try? await URLSession.shared.data(from: url) else {
            return nil
        }

        guard let httpResponse = response as? HTTPURLResponse else { return nil}
        guard httpResponse.statusCode == 200 else { return nil }

        let xml = XMLHash.parse(rawData)

        let result = xml["HamQTH"]["search"]

        return CallbookEntry(
            callsign: callsign,
            name: result["nick"].element?.text,
            qth: result["qth"].element?.text,
            gridsquare: result["grid"].element?.text,
            country: result["country"].element?.text,
            dxccId: (result["adif"].element?.text).flatMap(DXCC.init)
        )
    }
}
#endif
