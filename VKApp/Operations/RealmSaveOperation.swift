//
//  RealmSaveOperation.swift.swift
//  VKApp
//
//  Created by Alla Shkolnik on 08.04.2022.
//

import Foundation
import RealmSwift

final class RealmSaveOperation: AsyncOperation {
    private(set) var fetchedData: [RealmGroup] = []
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
            let fetchDataOperation = dependencies.first(where: { $0 is FetchDataOperation }) as? FetchDataOperation,
            let data = fetchDataOperation.fetchedData
        else {
            print("## Error. Data is not loaded from JSON")
            return
        }
        print("3 - parse from JSON to Realm")
        self.fetchedData = data.map { RealmGroup(fromDTO: $0) }
        print("4 - parse from JSON to Realm is finished")
        print("## fetchedData.count = \(String(describing: self.fetchedData.count))")
        saveToRealmIfNeeded()
        reloadRealmResults()
        self.state = .finished
    }
    
    // MARK: - Private methods
    private func saveToRealmIfNeeded() {
        guard let resultsCount = self.realmResults?.count else { return }
        if resultsCount < self.fetchedData.count {
            saveToRealm(fetchedData)
        } else {
            print("5 - realmResults?.count == fetchedData.count")
        }
    }
    
    private func saveToRealm(_ realmGroups: [RealmGroup]) {
        DispatchQueue.main.async {
            do {
                print("6 - save to Realm")
                try RealmService.save(items: realmGroups)
                self.updateRealmAppInfo()
                print("7 - save to Realm is finished")
                print("realmResults.count = \(String(describing: self.realmResults?.count))")
            } catch {
                print("## Error. can't load groups from Realm at \(#function): ", error)
            }
        }
    }
    
    private func updateRealmAppInfo() {
        realmUpdateDate = Date()
        let updateDate = RealmAppInfo(
            groupsUpdateDate: realmUpdateDate,
            friendsUpdateDate: AppDataInfo.shared.friendsUpdateDate
        )
        DispatchQueue.main.async {
            do {
                print("5 - save date of updating to Realm")
                try RealmService.save(items: [updateDate])
            } catch {
                print("## Error. can't save date of updating groups to Realm: ", error)
            }
        }
    }
    
    private func reloadRealmResults() {
        print("5 - load data from Realm")
        let updateInterval: TimeInterval = 60 * 60
        let needToBeUpdatedDate = Date(timeIntervalSinceNow: -updateInterval)
        if self.realmUpdateDate >= needToBeUpdatedDate || self.realmResults == nil {
            DispatchQueue.main.async {
                do {
                    self.realmResults = try RealmService.load(typeOf: RealmGroup.self)
                } catch {
                    print("## Error. Data is not loaded from Realm")
                }
            }
        }
        print("6 - load data from Realm is finished")
        print("## realmResults.count = \(String(describing: self.realmResults?.count))")
    }
}
