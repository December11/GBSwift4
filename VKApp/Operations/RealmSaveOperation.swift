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
        print("## 2. fetchedData.count = \( String(describing: self.fetchedData.count))")
        saveToRealmIfNeeded()
        reloadRealmResults()
        print("## 6. realmResults.count = \( String(describing: self.realmResults?.count))")
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
        print("## 3. realmResults.count = \( String(describing: self.realmResults?.count))")
        if realmResults == nil || resultsCount < fetchedData.count {
            saveToRealm(fetchedData)
        }
    }
    
    private func saveToRealm(_ realmGroups: [RealmGroup]) {
//        DispatchQueue.main.async {
            do {
                try RealmService.save(items: realmGroups)
                print("## 4. data (\(realmGroups.count)) saved to Realm")
                self.updateRealmAppInfo()
            } catch {
                print("## Error. can't load groups from Realm: ", error)
            }
//        }
    }
    
    private func updateRealmAppInfo() {
        realmUpdateDate = Date()
        let updateDate = RealmAppInfo(
            groupsUpdateDate: realmUpdateDate,
            friendsUpdateDate: AppDataInfo.shared.friendsUpdateDate
        )
//        DispatchQueue.main.async {
            do {
                try RealmService.save(items: [updateDate])
            } catch {
                print("## Error. can't save date of updating groups to Realm: ", error)
            }
//        }
    }
    
    private func reloadRealmResults() {
        let updateInterval: TimeInterval = 60 * 60
        let needToBeUpdatedDate = Date(timeIntervalSinceNow: -updateInterval)
        if self.realmUpdateDate >= needToBeUpdatedDate || self.realmResults == nil {
//            DispatchQueue.main.async {
                do {
                    self.realmResults = try RealmService.load(typeOf: RealmGroup.self)
                    print("## 5. Reload. realmResults.count = \(String(describing: self.realmResults?.count))")
                } catch {
                    print("## Error. Data is not loaded from Realm")
                }
//            }
        }
    }
}
