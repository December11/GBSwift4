//
//  RealmService.swift
//  VKApp
//
//  Created by Alla Shkolnik on 26.02.2022.
//

import Foundation
import RealmSwift

final class RealmService {
    static let deleteMigration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    
    class func save<T: Object>(
        items: [T],
        configuration: Realm.Configuration = deleteMigration,
        update: Realm.UpdatePolicy = .modified) throws {
            let realm = try Realm(configuration: configuration)
            print(configuration.fileURL ?? "")
            try realm.write({
                realm.add(items, update: update)
            })
    }
    
    class func load<T: Object>(typeOf: T.Type) throws -> Results<T> {
        let realm = try Realm()
        return realm.objects(T.self)
    }
    
    class func load<T: Object>(typeOf: T.Type) throws -> [T] {
        let realm = try Realm()
        return realm.objects(T.self).map { $0 }
    }
    
    class func delete<T: Object>(objects: Results<T>) throws {
        let realm = try Realm()
        try realm.write({
            realm.delete(objects)
        })
    }
    
    class func delete<T: Object>(object: T) throws {
        let realm = try Realm()
        try realm.write({
            realm.delete(object)
        })
    }
}
