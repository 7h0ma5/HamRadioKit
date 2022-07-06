//
//  File.swift
//  
//
//  Created by Thomas Gatzweiler on 06.07.22.
//

import Foundation

protocol Callbook {
    func lookup(callsign: String) async -> CallbookEntry?
}
