//
//  GetRealmDataOperation.swift
//  VKApp
//
//  Created by Alla Shkolnik on 09.04.2022.
//

import Foundation
import RealmSwift

final class GetRealmDataOperation: AsyncOperation {
    private(set) var realmResults: Results<RealmGroup>?
    private var realmUpdateDate = Date(timeIntervalSince1970: 0)
    
    override init() {
//        do {
//            let date = try RealmService.load(typeOf: RealmAppInfo.self).first?.groupsUpdateDate
//            self.realmUpdateDate = date ?? Date(timeIntervalSince1970: 0)
//        } catch {
//            print("## Error. Can't load groups update date from Realm", error)
//        }
    }
    
    override func main() {
        print("## processing GetRealmDataOperation.main()")
        guard
            let realmOperation = dependencies.first as? RealmOperation,
            let data = realmOperation.realmResults
        else {
            print("## Error. Data is not loaded from JSON")
            return
        }
        
        print("## 8 - Start read data from realm")
        self.realmResults = data
        print("## fetchedData.count = \(String(describing: self.realmResults?.count))")
//        getRealmData()
    }
    
    private func getRealmData() {
        do {
            print("5 - load data from Realm")
            let updateInterval: TimeInterval = 60 * 60
            if self.realmUpdateDate >= Date(timeIntervalSinceNow: -updateInterval) {
                self.realmResults = try RealmService.load(typeOf: RealmGroup.self)
            }
            print("c - load data from Realm is finished")
            print("realmResults.count = \(String(describing: realmResults?.count))")
        } catch {
            print("## Error. Data is not loaded from Realm")
        }
    }
}
