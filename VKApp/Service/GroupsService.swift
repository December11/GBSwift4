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
    var realmGroupResults: Results<RealmGroup>?
    
    private var realmUpdateDate = Date(timeIntervalSince1970: 0)
    
    private init() {
        do {
            let date = try RealmService.load(typeOf: RealmAppInfo.self).first?.groupsUpdateDate
            self.realmUpdateDate = date ?? Date(timeIntervalSince1970: 0)
        } catch {
            print(error)
        }
    }
    
    func loadDataIfNeeded() {
        // DispatchQueue.main.async {
            do {
                let updateInterval: TimeInterval = 60 * 60
                if self.realmUpdateDate >= Date(timeIntervalSinceNow: -updateInterval) {
                    self.realmGroupResults = try RealmService.load(typeOf: RealmGroup.self)
                } else {
                    self.fetchMyGroupsFromJSON()
                }
            } catch {
                print(error)
            }
        // }
    }
    
    func getGroups() throws -> [Group]? {
        loadDataIfNeeded()
        if let realmGroups = self.realmGroupResults {
            return fetchGroupsFromRealm(realmGroups.map { $0 })
        }
        return nil
    }
    
    // MARK: - Methods
    func saveGroupsToRealm(_ realmGroups: [RealmGroup]) {
        DispatchQueue.main.async {
            do {
                try RealmService.save(items: realmGroups)
                let realmUpdateDate = RealmAppInfo(
                    groupsUpdateDate: Date(),
                    friendsUpdateDate: AppDataInfo.shared.friendsUpdateDate
                )
                try RealmService.save(items: [realmUpdateDate])
                self.realmGroupResults = try RealmService.load(typeOf: RealmGroup.self)
                self.updateGroups(realmGroups)
            } catch {
                print(error)
            }
        }
    }
    
    func deleteGroupFromRealm(_ realmGroup: RealmGroup) {
        DispatchQueue.main.async {
            do {
                let group = Group(group: realmGroup)
                if let index = self.groups.firstIndex(of: group) {
                    self.groups.remove(at: index)
                }
                try RealmService.delete(object: realmGroup)
            } catch {
                print(error)
            }
        }
    }
    
    func getGroupByID(_ id: Int) -> Group? {
        var result: Group?
        let groupFromRealm = loadObjectFromRealmByID(id)
        if let group = groupFromRealm {
            result = group
        }
        if result == nil {
            print(print("### a. getGroupByID is nil"))
        }
        return result
    }
    
    // MARK: - Private methods
    private func loadObjectFromRealmByID(_ id: Int) -> Group? {
        guard
            let realmGroups = self.realmGroupResults?.filter({ $0.id == -id })
        else {
            
            print(print("### a. loadObjectFromRealmByID is nil"))
            return nil
        }
        return realmGroups.map { Group(group: $0) }.first
    }
    
    // MARK: - Private methods
    private func updateGroups(_ realmGroups: [RealmGroup]) {
        groups = realmGroups.map { Group(group: $0) }
    }
    
    private func fetchGroupsFromRealm(_ realmGroups: [RealmGroup]) -> [Group] {
        realmGroups.map { Group(group: $0) }
    }

    private func fetchMyGroupsFromJSON() {
        let groupsService = NetworkService<GroupDTO>()
        groupsService.path = "/method/groups.get"
        groupsService.queryItems = [
            URLQueryItem(name: "user_id", value: String(SessionStorage.shared.userId)),
            URLQueryItem(name: "extended", value: "1"),
            URLQueryItem(name: "fields", value: "description"),
            URLQueryItem(name: "access_token", value: SessionStorage.shared.token),
            URLQueryItem(name: "v", value: "5.131")
        ]
        groupsService.fetch { [weak self] groupsDTO in
            switch groupsDTO {
            case .failure(let error):
                print(error)
            case .success(let groupsDTO):
                let color = CGColor.generateLightColor()
                let realmGroups = groupsDTO.compactMap({ groupDTO -> RealmGroup? in
                    if groupDTO.isMember == 1 {
                        return RealmGroup(group: groupDTO, color: color)
                    }
                    return nil
                })
                self?.saveGroupsToRealm(realmGroups)
            }
        }
    }
}
