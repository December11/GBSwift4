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
            self.realmResults = try RealmService.load(typeOf: RealmGroup.self)
            let date = try RealmService.load(typeOf: RealmAppInfo.self).first?.groupsUpdateDate
            self.realmUpdateDate = date ?? Date(timeIntervalSince1970: 0)
        } catch {
            print("## Error. Can't load groups update date from Realm", error)
        }
    }
    
    func loadDataIfNeeded() {
        let updateInterval: TimeInterval = 60 * 60
        let expiredDate = Date(timeIntervalSinceNow: -updateInterval)
        if realmUpdateDate < expiredDate || realmResults?.count == 0 {
            fetchFromJSON()
        }
    }
    
    func fetchFromJSON() {
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
        }
        
        fetchDataQueue.addOperation(fetchData)
        OperationQueue.main.addOperation(realmGroups)
        OperationQueue.main.addOperation(realmData)
    }
    
    func getGroups() throws -> [Group]? {
        if let realmGroups = self.realmResults {
            return self.fetchFromRealm(realmGroups.map { $0 })
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
                print("## Error. Can't save groups to Realm. ", error)
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
        guard
            let realmGroups = self.realmResults?.filter({ $0.id == -id })
        else {
            print("## Error. Don't find group with id \(id)")
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
