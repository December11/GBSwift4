//
//  FetchRealmData.swift
//  VKApp
//
//  Created by Alla Shkolnik on 08.04.2022.
//

import Foundation
import RealmSwift

final class FetchRealmDataOperation: AsyncOperation {
    private(set) var realmResults: Results<RealmGroup>?
    private var realmUpdateDate = Date(timeIntervalSince1970: 0)
    
    override init() {
        do {
            let date = try RealmService.load(typeOf: RealmAppInfo.self).first?.groupsUpdateDate
            self.realmUpdateDate = date ?? Date(timeIntervalSince1970: 0)
        } catch {
            print("## Error. Can't load groups update date from Realm", error)
        }
    }
    
    override func main() {
        guard
            let realmOperation = dependencies.first(where: { $0 is RealmOperation }) as? RealmOperation
        else {
            print("## Error. Couldn't find dependencies from RealmOperation")
            return
        }
        do {
            print("5 - load data from Realm")
            let updateInterval: TimeInterval = 60 * 60
            if self.realmUpdateDate >= Date(timeIntervalSinceNow: -updateInterval) {
                self.realmResults = try RealmService.load(typeOf: RealmGroup.self)
            } else {
                self.realmResults = realmOperation.realmResults
            }
            print("c - load data from Realm is finished")
            print("realmResults.count = \(String(describing: realmResults?.count))")
        } catch {
            print("## Error. Data is not loaded from Realm")
        }
    }
}
