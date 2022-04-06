//
//  DataTransferService.swift
//  VKApp
//
//  Created by Alla Shkolnik on 29.03.2022.
//

import RealmSwift
import UIKit

final class UsersService {
    
    static let instance = UsersService()
    
    var users = [User]()
    var realmResults: Results<RealmUser>?
    
    private var realmUpdateDate = Date(timeIntervalSince1970: 0)
    
    private init() {
            do {
                let date = try RealmService.load(typeOf: RealmAppInfo.self).first?.friendsUpdateDate
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
                    self.realmResults = try RealmService.load(typeOf: RealmUser.self)
                } else {
                    self.fetchFromJSON()
                }
            } catch {
                print(error)
            }
        }
    }
    
    func getUsers() -> [User]? {
        loadDataIfNeeded()
        if let realmFriends = self.realmResults {
            let users = fetchFromRealm(realmFriends.map { $0 })
            return users
        }
        return nil
    }
    
    func getByID(_ id: Int) -> User? {
        var result: User?
        let userFromRealm = loadFromRealmByID(id)
        if let user = userFromRealm {
            result = user
        }
        return result
    }
    
    // MARK: - Private methods
    private func loadFromRealmByID(_ id: Int) -> User? {
        guard
            let realmUsers = self.realmResults?.filter({ $0.id == id })
        else {
            return nil
        }
        return realmUsers.map { User(user: $0) }.first
    }
    
    private func updateUsers(_ realmUsers: [RealmUser]) {
        users = realmUsers.map { User(user: $0)}
    }
    
    private func fetchFromRealm(_ realmUsers: [RealmUser]) -> [User] {
        let res = realmUsers.map { User(user: $0) }
        return res
    }
    
    private func fetchFromJSON() {
        let usersService = NetworkService<UserDTO>()
        usersService.path = "/method/friends.get"
        usersService.queryItems = [
            URLQueryItem(name: "user_id", value: String(SessionStorage.shared.userId)),
            URLQueryItem(name: "order", value: "name"),
            URLQueryItem(name: "fields", value: "photo_50"),
            URLQueryItem(name: "access_token", value: SessionStorage.shared.token),
            URLQueryItem(name: "v", value: "5.131")
        ]
        DispatchQueue.global().async {
            usersService.fetch { [weak self] usersDTOObjects in
                switch usersDTOObjects {
                case .failure(let error):
                    print(error)
                case .success(let usersDTO):
                    let color = CGColor.generateLightColor()
                    var realmUsers = usersDTO.map { RealmUser(user: $0, color: color) }
                    realmUsers = realmUsers.filter { $0.deactivated == nil }
                    self?.saveToRealm(realmUsers)
                }
            }
        }
    }
    
    private func saveToRealm(_ realmUsers: [RealmUser]) {
        DispatchQueue.main.async {
            do {
                try RealmService.save(items: realmUsers)
                let realmUpdateDate = RealmAppInfo(
                    groupsUpdateDate: AppDataInfo.shared.groupsUpdateDate,
                    friendsUpdateDate: Date()
                )
                try RealmService.save(items: [realmUpdateDate])
                self.realmResults = try RealmService.load(typeOf: RealmUser.self)
                self.updateUsers(realmUsers)
            } catch {
                print(error)
            }
        }
    }
}
