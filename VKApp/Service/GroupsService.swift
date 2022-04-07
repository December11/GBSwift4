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
            print(error)
        }
    }
    
    func loadDataIfNeeded() {
        DispatchQueue.main.async {
            do {
                let updateInterval: TimeInterval = 60 * 60
                if self.realmUpdateDate >= Date(timeIntervalSinceNow: -updateInterval) {
                    self.realmResults = try RealmService.load(typeOf: RealmGroup.self)
                } else {
                    self.fetchFromJSON()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func getGroups() throws -> [Group]? {
        loadDataIfNeeded()
        if let realmGroups = self.realmResults {
            return fetchFromRealm(realmGroups.map { $0 })
        }
        return nil
    }
    
    // MARK: - Methods
    func saveToRealm(_ realmGroups: [RealmGroup]) {
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
            print(error)
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
                print(error)
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

    private func fetchFromJSON() {
        let dispatchGroup = DispatchGroup()
        let groupsService = NetworkService<GroupDTO>()
        groupsService.path = "/method/groups.get"
        groupsService.queryItems = [
            URLQueryItem(name: "user_id", value: String(SessionStorage.shared.userId)),
            URLQueryItem(name: "extended", value: "1"),
            URLQueryItem(name: "fields", value: "description"),
            URLQueryItem(name: "access_token", value: SessionStorage.shared.token),
            URLQueryItem(name: "v", value: "5.131")
        ]
        DispatchQueue.global().async(group: dispatchGroup) {
            groupsService.fetch { [weak self] groupsDTO in
                switch groupsDTO {
                case .failure(let error):
                    print(error)
                case .success(let groupsDTO):
                    let realmGroups = groupsDTO.compactMap({ groupDTO -> RealmGroup? in
                        if groupDTO.isMember == 1 {
                            return RealmGroup(fromDTO: groupDTO)
                        }
                        return nil
                    })
                    dispatchGroup.notify(queue: DispatchQueue.main) {
                        self?.saveToRealm(realmGroups)
                    }
                }
            }
        }
    }
}
