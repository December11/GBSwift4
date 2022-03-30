//
//  AppDataUpdateInfo.swift
//  VKApp
//
//  Created by Alla Shkolnik on 03.03.2022.
//

import Foundation

class AppDataInfo {
    static let shared = AppDataInfo()
    
    var friendsUpdateDate: Date?
    var groupsUpdateDate: Date?
    var feedUpdateDate: Date?
    
    private init() {}
}
