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
    
    var myGroups = [Group]()
    var realmGroupResults: Results<RealmGroup>?
    
    private init() {}
    
    func updateData() throws {
        do {
            let updateInterval: TimeInterval = 60 * 1
            if let updateInfo = try RealmService.load(typeOf: RealmAppInfo.self).first,
               let groupsUpdateDate = updateInfo.groupsUpdateDate,
               groupsUpdateDate >= Date(timeIntervalSinceNow: -updateInterval) {
                let realmGroupResults: Results<RealmGroup> = try RealmService.load(typeOf: RealmGroup.self)
                self.realmGroupResults = realmGroupResults
                updateGroups(realmGroupResults.map { $0 })
            } else {
                fetchMyGroupsFromJSON()
            }
        } catch {
            print(error)
        }
    }
    
    func getData() throws -> [Group]? {
        do {
            try updateData()
            if let realmGroups = realmGroupResults {
                return fetchGroupsFromRealm(realmGroups.map { $0 })
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    // MARK: - Methods
    func getGroupByID(_ id: Int) -> Group? {
        let realmGroups = realmGroupResults.map { $0 }
        guard
            let realmGroups = realmGroups,
            let realmGroup = realmGroups.filter({ $0.id == -id }).first
        else { return nil }
        return Group(group: realmGroup)
    }
    
    func saveGroupsToRealm(_ realmGroups: [RealmGroup]) {
        do {
            try RealmService.save(items: realmGroups)
            AppDataInfo.shared.groupsUpdateDate = Date()
            let realmUpdateDate = RealmAppInfo(
                groupsUpdateDate: AppDataInfo.shared.groupsUpdateDate,
                friendsUpdateDate: AppDataInfo.shared.friendsUpdateDate
            )
            try RealmService.save(items: [realmUpdateDate])
            updateGroups(realmGroups)
        } catch {
            print(error)
        }
    }
    
    func deleteGroupFromRealm(_ realmGroup: RealmGroup) {
        do {
            let group = Group(group: realmGroup)
            if let index = myGroups.firstIndex(of: group) {
                myGroups.remove(at: index)
            }
            try RealmService.delete(object: realmGroup)
        } catch {
            print(error)
        }
    }
    
    // MARK: - Private methods
    private func updateGroups(_ realmGroups: [RealmGroup]) {
        myGroups = realmGroups.map { Group(group: $0) }
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
                DispatchQueue.main.async {
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
}
