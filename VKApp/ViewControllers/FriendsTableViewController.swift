//
//  FriendsTableViewController.swift
//  VKApp
//
//  Created by Alla Shkolnik on 18.12.2021.
//

import RealmSwift
import UIKit
import WebKit

class FriendsTableViewController: UITableViewController {
    
    private let helper = UserHelper()
    private let userService = UsersService.instance
    private var friendsToken: NotificationToken?
    var friends = [User]()
    
    // MARK: - Данные для экрана Фото
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotos" {
            guard
                let photosController = segue.destination
                    as? FriendCollectionViewController,
                let indexPath = sender as? IndexPath
            else { return }
            let currentFriend = getCurrentUser(for: indexPath)
            photosController.friend = currentFriend
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(for: ImageCell.self)
        if let fetchedData = userService.getUsers() {
            friends = fetchedData
        }
        realmNotify()
    }
    
    deinit {
        friendsToken?.invalidate()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        VKWVLoginViewController.keychain.delete("accessToken")
        VKWVLoginViewController.keychain.delete("userID")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let view = storyboard.instantiateViewController(withIdentifier: "VKWVLoginViewController")
                as? VKWVLoginViewController else { return }
        view.loadView()
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords( ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach {
                if $0.displayName.contains("vk") {
                    dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [$0]) {
                        guard
                            let url = view.urlComponents.url
                        else { return }
                        view.webView.load(URLRequest(url: url))
                    }
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private methods
    private func realmNotify() {
        friendsToken = userService.realmResults?.observe({ [weak self] friendChanges in
            guard let self = self else { return }
            switch friendChanges {
            case .initial:
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
                print("## Error. Can't reload friends tableView", error)
            }
        })
    }
    
    private func getCurrentUser(for indexPath: IndexPath) -> User {
        let currentSectionNumber = indexPath.section
        let currentKeys = helper.getSortedKeyArray(for: friends)[currentSectionNumber]
        let friendsForCurrentKey = helper.getArrayForKey(from: friends, for: currentKeys)
        return friendsForCurrentKey[indexPath.row]
    }

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
        let cell: ImageCell = tableView.dequeueReusableCell(for: indexPath)
        let currentFriend = getCurrentUser(for: indexPath)
        if indexPath.row <= 2 {
        }
    
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
