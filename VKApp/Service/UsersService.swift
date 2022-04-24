//
//  DataTransferService.swift
//  VKApp
//
//  Created by Alla Shkolnik on 29.03.2022.
//

import PromiseKit
import RealmSwift
import UIKit

enum AppError: Error {
    case noDataProvided
    case failedToDecode
    case errorTask
    case notCorrectUrl
}

final class UsersService {
    
    static let instance = UsersService()
    
    var users = [User]()
    var realmResults: Results<RealmUser>?
    
    private var realmUpdateDate = Date(timeIntervalSince1970: 0)
    
    private init() {
        do {
            self.realmResults = try RealmService.load(typeOf: RealmUser.self)
            let date = try RealmService.load(typeOf: RealmAppInfo.self).first?.friendsUpdateDate
            self.realmUpdateDate = date ?? Date(timeIntervalSince1970: 0)
        } catch {
            print("## Error. Can't load friends update date from Realm", error)
        }
    }
    
    func loadDataIfNeeded() {
        do {
            let updateInterval: TimeInterval = 60 * 60
            if realmUpdateDate >= Date(timeIntervalSinceNow: -updateInterval) {
                realmResults = try RealmService.load(typeOf: RealmUser.self)
            } else {
                fetchUsersFromJSONAndSaveToRealm()
            }
        } catch {
            print("## Error. Can't load users from Realm", error)
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
        guard
            let realmUsers = self.realmResults?.filter({ $0.id == id })
        else {
            return nil
        }
        return realmUsers.map { User(fromRealm: $0) }.first
    }
    
    // MARK: - Private methods
    private func updateUsers(_ realmUsers: [RealmUser]) {
        users = realmUsers.map { User(fromRealm: $0)}
    }
    
    private func fetchFromRealm(_ realmUsers: [RealmUser]) -> [User] {
        realmUsers.map { User(fromRealm: $0) }
    }
    
    private func getURL() -> Promise<URL> {
        let authService = AuthService.shared
        guard
            let userID = authService.keychain.get("userID"),
            let accessToken = authService.keychain.get("accessToken")
        else {
            print("## Error. Can't load userID or AccessToken from Keychain")
            return Promise.init(error: NSError())
        }
        
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.vk.com"
            components.path = "/method/friends.get"
            components.queryItems = [
                URLQueryItem(name: "user_id", value: userID),
                URLQueryItem(name: "order", value: "name"),
                URLQueryItem(name: "fields", value: "photo_50"),
                URLQueryItem(name: "access_token", value: accessToken),
                URLQueryItem(name: "v", value: "5.131")
            ]
            return components
        }
        
        return Promise { resolver in
            guard let url = urlComponents.url else {
                print("## Error. Can't get URL")
                resolver.reject(AppError.notCorrectUrl)
                return
            }
            resolver.fulfill(url)
        }
    }
    
    private func fetchData(_ url: URL) -> Promise<Data> {
        let session = URLSession.shared
        return Promise { resolver in
            let task = session.dataTask(with: url) { data, _, error in
                guard error == nil else {
                    print("## Error. Can't load data \(String(describing: error))")
                    resolver.reject(AppError.errorTask)
                    return
                }
                guard let data = data else {
                    print("## Error. Can't load data")
                    resolver.reject(AppError.noDataProvided)
                    return
                }
                resolver.fulfill(data)
            }
            task.resume()
        }
    }
    
    private func parseData(_ data: Data) -> Promise <[UserDTO]> {
        return Promise { resolver in
            do {
                if let usersDTO = try JSONDecoder().decode(ResponseDTO<UserDTO>.self, from: data).response.items {
                    resolver.fulfill(usersDTO)
                }
            } catch {
                print("## Error. can't load data from JSON", error)
                resolver.reject(AppError.failedToDecode)
            }
        }
    }
    
    private func fetchUsersFromJSONAndSaveToRealm() {
        var usersDTO = [UserDTO]()
        
        getURL()
        .then(on: .global()) { url in
            self.fetchData(url)
        }.then { data in
            self.parseData(data)
        }.done { users in
            usersDTO = users
            let realmUsers = self.convertToRealm(from: usersDTO)
            self.saveToRealm(realmUsers)
        }.catch { error in
            print("## Error. can't loador parse Data: \(error)")
        }
    }
    
    private func convertToRealm(from usersDTO: [UserDTO]) -> [RealmUser] {
        let users = usersDTO.map { RealmUser(fromDTO: $0) }.filter { $0.deactivated == nil }
        return users
    }
    
    private func saveToRealm(_ realmUsers: [RealmUser]) {
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
            print("## Error. Can't load users from Realm", error)
        }
    }
}
