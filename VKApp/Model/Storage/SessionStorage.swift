//
//  SessionStorage.swift
//  VKApp
//
//  Created by Alla Shkolnik on 09.02.2022.
//

import Foundation

final class SessionStorage {
    static let shared = SessionStorage()
    
    var token = ""
    var userId = 0
    
    private init() { }
}
