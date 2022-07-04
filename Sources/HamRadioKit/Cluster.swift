//
//  Cluster.swift
//  QLog
//
//  Created by Thomas Gatzweiler on 26.05.22.
//

import Foundation
import Network

public class Cluster {
    public static let shared = Cluster()
    
    
    init() {
        
    }
    
    public func connect() async  {
        UserDefaults.standard.string(forKey: "cluster.username")
        UserDefaults.standard.string(forKey: "cluster.password")
    }
}
