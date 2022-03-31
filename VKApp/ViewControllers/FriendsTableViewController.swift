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
