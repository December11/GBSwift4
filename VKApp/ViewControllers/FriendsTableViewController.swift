//
//  FriendsTableViewController.swift
//  VKApp
//
//  Created by Alla Shkolnik on 18.12.2021.
//

import UIKit
import RealmSwift

class FriendsTableViewController: UITableViewController {
    
    private let helper = UserHelper()
    private let friendsService = NetworkService<UserDTO>()
    private let userService = UsersService.instance
    
    private var friendsToken: NotificationToken?
    private var realmFriendResults: Results<RealmUser>?
    var friends = [User]()
    
    // MARK: - Данные для экрана Фото
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotos" {
            guard
                let photosController = segue.destination
                    as? FriendCollectionViewController,
                let indexPath = sender as? IndexPath
            else { return }
            let currentSectionNumber = indexPath.section
            let currentKeys = helper.getSortedKeyArray(for: friends)[currentSectionNumber]
            let friendsForCurrentKey = helper.getArrayForKey(from: friends, for: currentKeys)
            let currentFriend = friendsForCurrentKey[indexPath.row]
            photosController.friend = currentFriend
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(
            UINib(nibName: "ImageCell", bundle: nil),
            forCellReuseIdentifier: "imageCell")
        
        do {
            if let fetchedData = try userService.getData() {
                friends = fetchedData
            }
        } catch {
            print(error)
        }
            
        
//        do {
//            let updateInterval: TimeInterval = 60 * 60
//            if let updateInfo = try RealmService.load(typeOf: RealmAppInfo.self).first,
//               let friendsUpdateDate = updateInfo.friendsUpdateDate,
//               friendsUpdateDate >= Date(timeIntervalSinceNow: -updateInterval) {
//                let realmFriends: Results<RealmUser> = try RealmService.load(typeOf: RealmUser.self)
//                self.realmFriendResults = realmFriends
//                updateFriends(realmFriends.map { $0 })
//            } else {
//                fetchFriendsByJSON()
//            }
//        } catch {
//            print(error)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        friendsToken = userService.realmFriendResults?.observe({ [weak self] friendChanges in
            guard let self = self else { return }
            switch friendChanges {
            case .initial(_):
                self.tableView.reloadData()
            case .update(_, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                print(deletions, insertions, modifications)
                self.tableView.beginUpdates()
                
                let deletionIndexPath = deletions.map {
                    IndexPath(row: $0, section: self.tableView.sectionOf(row: $0) ?? 0)
                }
                let insertionIndexPath = insertions.map {
                    IndexPath(row: $0, section: self.tableView.sectionOf(row: $0) ?? 0)
                }
                let modificateIndexPath = modifications.map {
                    IndexPath(row: $0, section: self.tableView.sectionOf(row: $0) ?? 0)
                }
                self.tableView.deleteRows(at: deletionIndexPath, with: .automatic)
                self.tableView.insertRows(at: insertionIndexPath, with: .automatic)
                self.tableView.reloadRows(at: modificateIndexPath, with: .automatic)
                self.tableView.endUpdates()
            case .error(let error):
                print(error)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        friendsToken?.invalidate()
    }
    
    @IBAction func dismiss() {
        dismiss(animated: true)
    }
    
//    // MARK: - Private methods
//    private func fetchFriendsByJSON() {
//        friendsService.path = "/method/friends.get"
//        friendsService.queryItems = [
//            URLQueryItem(name: "user_id", value: String(SessionStorage.shared.userId)),
//            URLQueryItem(name: "order", value: "name"),
//            URLQueryItem(name: "fields", value: "photo_50"),
//            URLQueryItem(name: "access_token", value: SessionStorage.shared.token),
//            URLQueryItem(name: "v", value: "5.131")
//        ]
//        friendsService.fetch { [weak self] friendsDTOObjects in
//            switch friendsDTOObjects {
//            case .failure(let error):
//                print(error)
//            case .success(let friendsDTO):
//                DispatchQueue.main.async {
//                    let color = CGColor.generateLightColor()
//                    var realmFriends = friendsDTO.map { RealmUser(user: $0, color: color) }
//                    realmFriends = realmFriends.filter { $0.deactivated == nil }
//                    self?.saveFriendsToRealm(realmFriends)
//                }
//            }
//        }
//    }
//
//    private func updateFriends(_ realmFriends: [RealmUser]) {
//        friends = realmFriends.map({ realmFriend in
//            User(
//                id: realmFriend.id,
//                firstName: realmFriend.firstName,
//                secondName: realmFriend.secondName,
//                userPhotoURLString: realmFriend.userPhotoURLString
//            )
//        })
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//        }
//    }
//
//    private func saveFriendsToRealm(_ realmFriends: [RealmUser]) {
//        do {
//            try RealmService.save(items: realmFriends)
//            AppDataInfo.shared.friendsUpdateDate = Date()
//            let realmUpdateDate = RealmAppInfo(
//                groupsUpdateDate: AppDataInfo.shared.groupsUpdateDate,
//                friendsUpdateDate: AppDataInfo.shared.friendsUpdateDate,
//                feedUpdateDate: AppDataInfo.shared.feedUpdateDate
//            )
//            try RealmService.save(items: [realmUpdateDate])
//            updateFriends(realmFriends)
//        } catch {
//            print(error)
//        }
//    }

    // MARK: - Секции и вывод строк
    override func numberOfSections(in tableView: UITableView) -> Int {
        helper.getSortedKeyArray(for: friends).count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = helper.getSortedKeyArray(for: friends)
        return helper.getArrayForKey(from: friends, for: array[section]).count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        helper.getSortedKeyArray(for: friends)[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as? ImageCell
        else { return UITableViewCell() }
        
        // все чтобы получить нужного друга в нужной секции
        let currentSectionNumber = indexPath.section
        let currentKeys = helper.getSortedKeyArray(for: friends)[currentSectionNumber]
        let friendsForCurrentKey = helper.getArrayForKey(from: friends, for: currentKeys)
        let currentFriend = friendsForCurrentKey[indexPath.row]
        
        cell.configureCell(
            label: currentFriend.firstName,
            additionalLabel: currentFriend.secondName,
            pictureURL: currentFriend.userPhotoURLString,
            color: currentFriend.codeColor)
        return cell
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        helper.getSortedKeyArray(for: friends)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView .deselectRow(at: indexPath, animated: true) }
        performSegue(withIdentifier: "showPhotos", sender: indexPath)
    }
}

extension FriendsTableViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}
