//
//  FriendStorage.swift
//  VKApp
//
//  Created by Alla Shkolnik on 04.01.2022.
//

import UIKit

final class UserHelper {
    
    func getIndexes(for array: [User]) -> [String: [User]] {
        var dictionary = [String: [User]]()
        for friend in array {
            let key = friend.secondName == ""
            ?  String(friend.firstName.prefix(1))
            :  String(friend.secondName.prefix(1))
            if !dictionary.keys.contains(key) {
                let tmpArray = getArrayForKey(from: array, for: key)
                dictionary.updateValue(tmpArray, forKey: key)
            }
        }
        return dictionary
    }
    
    func getArrayForKey(from array: [User], for key: String ) -> [User] {
        var tmpArray = [User]()
        for friend in array {
            let keyValue = friend.secondName == ""
            ?  String(friend.firstName.prefix(1))
            :  String(friend.secondName.prefix(1))
            if keyValue == key {
                tmpArray.append(friend)
            }
        }
        return tmpArray.sorted()
    }
    
    func getSortedKeyArray(for array: [User]) -> [String] {
        let array = [String](getIndexes(for: array).keys)
        return array.sorted()
    }
}


