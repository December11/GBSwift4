//
//  GroupsService.swift
//  VKApp
//
//  Created by Alla Shkolnik on 29.03.2022.
//

import RealmSwift
import UIKit

final class GroupsService {
    
    static let instance = GroupsService()
    
    var groups = [Group]()
    var realmResults: Results<RealmGroup>?
    private var realmUpdateDate = Date(timeIntervalSince1970: 0)
    
    private init() {
        do {
            let date = try RealmService.load(typeOf: RealmAppInfo.self).first?.groupsUpdateDate
            self.realmUpdateDate = date ?? Date(timeIntervalSince1970: 0)
        } catch {
            print("## Error. Can't load groups update date from Realm", error)
        }
    }
    
    func loadDataIfNeeded() {
        
        let updateInterval: TimeInterval = 60 * 60
        let lastUpdateDate = Date(timeIntervalSinceNow: -updateInterval)
        
        if realmUpdateDate >= lastUpdateDate {
            
        }
        
        let fetchDataQueue: OperationQueue = {
            let queue = OperationQueue()
            queue.qualityOfService = .utility
            queue.name = "fetchDataFromJSONQueue"
            return queue
        }()
        
        let fetchData = FetchDataOperation()
        let realmGroups = RealmSaveOperation()
        let realmData = RealmLoadOperation()
        
        realmGroups.addDependency(fetchData)
        realmData.addDependency(realmGroups)
        realmData.completionBlock = {
            self.realmResults = realmData.realmResults
            DispatchQueue.main.async {
                
                print("10 - Well, count of groups is \(String(describing: self.realmResults?.count))")
            }
        }
        
        fetchDataQueue.addOperation(fetchData)
        OperationQueue.main.addOperation(realmGroups)
        OperationQueue.main.addOperation(realmData)
    }
    
    func getGroups() throws -> [Group]? {
        loadDataIfNeeded()
        print("11 - Well, count of groups is \(String(describing: self.realmResults?.count))")
        if let realmGroups = self.realmResults {
            return fetchFromRealm(realmGroups.map { $0 })
        }
        return nil
    }
    
    // MARK: - Methods
    func saveToRealm(_ realmGroups: [RealmGroup]) {
        DispatchQueue.main.async {
            do {
                try RealmService.save(items: realmGroups)
                let realmUpdateDate = RealmAppInfo(
                    groupsUpdateDate: Date(),
                    friendsUpdateDate: AppDataInfo.shared.friendsUpdateDate
                )
                try RealmService.save(items: [realmUpdateDate])
                self.realmResults = try RealmService.load(typeOf: RealmGroup.self)
                self.updateGroups(realmGroups)
            } catch {
                print("## Error - Can't load groups from Realm. ", error)
                
            }
        }
    }
    
    func deleteFromRealm(_ realmGroup: RealmGroup) {
        DispatchQueue.main.async {
            do {
                let group = Group(fromRealm: realmGroup)
                if let index = self.groups.firstIndex(of: group) {
                    self.groups.remove(at: index)
                }
                try RealmService.delete(object: realmGroup)
            } catch {
                print("## Error. Can't delete group from Realm", error)
            }
        }
    }
    
    func getByID(_ id: Int) -> Group? {
        var result: Group?
        let groupFromRealm = loadFromRealmByID(id)
        if let group = groupFromRealm {
            result = group
        }
        if result == nil {
            print("### a. getGroupByID is nil")
        }
        return result
    }
    
    // MARK: - Private methods
    private func loadFromRealmByID(_ id: Int) -> Group? {
        guard
            let realmGroups = self.realmResults?.filter({ $0.id == -id })
        else {
            return nil
        }
        return realmGroups.map { Group(fromRealm: $0) }.first
    }
    
    // MARK: - Private methods
    private func updateGroups(_ realmGroups: [RealmGroup]) {
        groups = realmGroups.map { Group(fromRealm: $0) }
    }
    
    private func fetchFromRealm(_ realmGroups: [RealmGroup]) -> [Group] {
        realmGroups.map { Group(fromRealm: $0) }
    }
}
