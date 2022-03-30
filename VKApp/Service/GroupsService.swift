//
//  GroupsService.swift
//  VKApp
//
//  Created by Alla Shkolnik on 29.03.2022.
//

import UIKit
import RealmSwift

final class GroupsService {
    
    static let instance = GroupsService()
    
    var groups = [Group]()
    var realmGroupResults: Results<RealmGroup>?
    
    private init() {}
    
    func updateData() throws {
        do {
            let updateInterval: TimeInterval = 60 * 1
            if let updateInfo = try RealmService.load(typeOf: RealmAppInfo.self).first,
               let groupsUpdateDate = updateInfo.groupsUpdateDate,
               groupsUpdateDate >= Date(timeIntervalSinceNow: -updateInterval)  {
                let realmGroupResults: Results<RealmGroup> = try RealmService.load(typeOf: RealmGroup.self)
                self.realmGroupResults = realmGroupResults
                updateGroups(realmGroupResults.map { $0 })
            } else {
                fetchGroupsFromJSON()
            }
        } catch {
            print(error)
        }
    }
    
    func getData() throws -> [Group]? {
        do {
            try updateData()
            let realmGroups: Results<RealmGroup> = try RealmService.load(typeOf: RealmGroup.self)
            let groups = fetchGroupsFromRealm(realmGroups.map { $0 })
            return groups
        } catch {
            print(error)
        }
        return nil
    }
    
    // MARK: - Private methods
    private func updateGroups(_ realmGroups: [RealmGroup]) {
        groups = realmGroups.map({ realmGroup in
            Group(id: realmGroup.id, title: realmGroup.title, imageURL: realmGroup.groupPhotoURL)
        })
    }

    private func saveGroupsToRealm(_ realmGroups: [RealmGroup]) {
        do {
            try RealmService.save(items: realmGroups)
            AppDataInfo.shared.groupsUpdateDate = Date()
            let realmUpdateDate = RealmAppInfo(
                groupsUpdateDate: AppDataInfo.shared.groupsUpdateDate,
                friendsUpdateDate: AppDataInfo.shared.friendsUpdateDate,
                feedUpdateDate: AppDataInfo.shared.feedUpdateDate
            )
            try RealmService.save(items: [realmUpdateDate])
            updateGroups(realmGroups)
        } catch {
            print(error)
        }
    }
    
    private func fetchGroupsFromRealm(_ realmGroups: [RealmGroup]) -> [Group] {
        let groups = realmGroups.map({ realmGroup in
            Group(id: realmGroup.id, title: realmGroup.title, imageURL: realmGroup.groupPhotoURL)
        })
        return groups
    }

    private func fetchGroupsFromJSON() {
        //получаем список групп
        let groupsService = NetworkService<GroupDTO>()
        groupsService.path = "/method/groups.get"
        groupsService.queryItems = [
            URLQueryItem(name: "user_id", value: String(SessionStorage.shared.userId)),
            URLQueryItem(name: "extended", value: "1"),
            URLQueryItem(name: "fields", value: "description"),
            URLQueryItem(name: "access_token", value: SessionStorage.shared.token),
            URLQueryItem(name: "v", value: "5.131")
        ]
        groupsService.fetch { [weak self] groupsDTOObject in
            switch groupsDTOObject {
            case .failure(let error):
                print(error)
            case .success(let groupsDTO):
                DispatchQueue.main.async {
                    let color = CGColor.generateLightColor()
                    let realmGroups = groupsDTO.map({ RealmGroup(group: $0, color: color) })
                    self?.saveGroupsToRealm(realmGroups)
                }
            }
        }
    }
}
