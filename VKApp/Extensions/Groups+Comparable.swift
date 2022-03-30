//
//  GroupsEquatable.swift
//  VKApp
//
//  Created by Alla Shkolnik on 25.12.2021.
//

import Foundation

extension Group: Comparable {
    static func == (lhs: Group, rhs: Group) -> Bool {
        lhs.title == rhs.title
    }
    
    static func < (lhs: Group, rhs: Group) -> Bool {
        lhs.title < rhs.title
    }
}
