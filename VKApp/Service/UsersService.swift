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
    var friends = [User]()
    var realmFriendResults: Results<RealmUser>?
    
    private init() {}
    
    func updateData() throws {
        do {
            let updateInterval: TimeInterval = 60 * 1
            if let updateInfo = try RealmService.load(typeOf: RealmAppInfo.self).first,
               let friendsUpdateDate = updateInfo.friendsUpdateDate,
               friendsUpdateDate >= Date(timeIntervalSinceNow: -updateInterval) {
                let realmFriends: Results<RealmUser> = try RealmService.load(typeOf: RealmUser.self)
                self.realmFriendResults = realmFriends
            } else {
                fetchFriendsByJSON()
            }
        } catch {
            print(error)
        }
    }
    
    func getData() throws -> [User]? {
        do {
            try updateData()
            if let realmFriends = self.realmFriendResults {
                return fetchFriendsFromRealm(realmFriends.map { $0 })
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    // MARK: - Private methods
    private func updateFriendss(_ realmUsers: [RealmUser]) {
        friends = realmUsers.map { User(user: $0)}
    }
    
    private func fetchFriendsFromRealm(_ realmUsers: [RealmUser]) -> [User] {
        realmUsers.map { User(user: $0) }
    }
    
    private func fetchFriendsByJSON() {
        let friendsService = NetworkService<UserDTO>()
        friendsService.path = "/method/friends.get"
        friendsService.queryItems = [
            URLQueryItem(name: "user_id", value: String(SessionStorage.shared.userId)),
            URLQueryItem(name: "order", value: "name"),
            URLQueryItem(name: "fields", value: "photo_50"),
            URLQueryItem(name: "access_token", value: SessionStorage.shared.token),
            URLQueryItem(name: "v", value: "5.131")
        ]
        friendsService.fetch { [weak self] friendsDTOObjects in
            switch friendsDTOObjects {
            case .failure(let error):
                print(error)
            case .success(let friendsDTO):
                DispatchQueue.main.async {
                    let color = CGColor.generateLightColor()
                    var realmFriends = friendsDTO.map { RealmUser(user: $0, color: color) }
                    realmFriends = realmFriends.filter { $0.deactivated == nil }
                    self?.saveFriendsToRealm(realmFriends)
                }
            }
        }
    }
    
    private func saveFriendsToRealm(_ realmFriends: [RealmUser]) {
        do {
            try RealmService.save(items: realmFriends)
            AppDataInfo.shared.friendsUpdateDate = Date()
            let realmUpdateDate = RealmAppInfo(
                groupsUpdateDate: AppDataInfo.shared.groupsUpdateDate,
                friendsUpdateDate: AppDataInfo.shared.friendsUpdateDate
            )
            try RealmService.save(items: [realmUpdateDate])
        } catch {
            print(error)
        }
    }
}
