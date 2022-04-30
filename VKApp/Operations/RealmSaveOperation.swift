//
//  RealmSaveOperation.swift.swift
//  VKApp
//
//  Created by Alla Shkolnik on 08.04.2022.
//

import Foundation
import RealmSwift

final class RealmSaveOperation: AsyncOperation {
    private var fetchedData = [RealmGroup]()
    private var savingGroups: [RealmGroup]?
    private(set) var realmResults: Results<RealmGroup>?
    private var realmUpdateDate = Date(timeIntervalSince1970: 0)
    
    init(data: [RealmGroup]?) {
        do {
            let date = try RealmService.load(typeOf: RealmAppInfo.self).first?.groupsUpdateDate
            self.realmUpdateDate = date ?? Date(timeIntervalSince1970: 0)
        } catch {
            print("## Error. Can't load groups update date from Realm", error)
        }
        self.savingGroups = data
    }
    
    override func main() {
        loadFetchedData()
        saveToRealmIfNeeded()
        reloadRealmResults()
        self.state = .finished
    }
    
    // MARK: - Private methods
    
    private func loadFetchedData() {
        if let groups = savingGroups {
            fetchedData.append(contentsOf: groups)
        } else {
            guard
                let prevOperation = dependencies.first as? FetchDataOperation,
                let data = prevOperation.fetchedData
            else { return }
            fetchedData = data.map { RealmGroup(fromDTO: $0) }
        }
    }
    
    private func saveToRealmIfNeeded() {
       let resultsCount = realmResults?.count ?? 0
        if realmResults == nil || resultsCount < fetchedData.count {
            saveToRealm(fetchedData)
        }
    }
    
    private func saveToRealm(_ realmGroups: [RealmGroup]) {
        do {
            try RealmService.save(items: realmGroups)
            self.updateRealmAppInfo()
        } catch {
            print("## Error. can't load groups from Realm: ", error)
        }
    }
    
    private func updateRealmAppInfo() {
        realmUpdateDate = Date()
        let updateDate = RealmAppInfo(
            groupsUpdateDate: realmUpdateDate,
            friendsUpdateDate: AppDataInfo.shared.friendsUpdateDate
        )
        do {
            try RealmService.save(items: [updateDate])
        } catch {
            print("## Error. can't save date of updating groups to Realm: ", error)
        }
    }
    
    private func reloadRealmResults() {
        let updateInterval: TimeInterval = 60 * 60
        let needToBeUpdatedDate = Date(timeIntervalSinceNow: -updateInterval)
        if self.realmUpdateDate >= needToBeUpdatedDate || self.realmResults == nil {
            do {
                self.realmResults = try RealmService.load(typeOf: RealmGroup.self)
            } catch {
                print("## Error. Data is not loaded from Realm")
            }
        }
    }
}
