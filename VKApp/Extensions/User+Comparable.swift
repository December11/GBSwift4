//
//  FriendsComparable.swift
//  VKApp
//
//  Created by Alla Shkolnik on 04.01.2022.
//

import Foundation

extension User: Comparable {
    static func < (lhs: User, rhs: User) -> Bool {
        lhs.secondName < rhs.secondName
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.userName == rhs.userName
    }
}
