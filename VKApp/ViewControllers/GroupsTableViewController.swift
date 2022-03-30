//
//  GroupsTableViewController.swift
//  VKApp
//
//  Created by Alla Shkolnik on 18.12.2021.
//

import UIKit
import RealmSwift

class GroupsTableViewController: UITableViewController {
    
    var groups = [Group]()
    var realmGroupResults: Results<RealmSavedGroup>?
    private var groupToken: NotificationToken?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == "addGroup",
            let allGroupsViewController = segue.destination as? AllGroupTableViewController
        else { return }
        allGroupsViewController.completion = { [weak self] group in
            guard let self = self else { return }
            if !self.groups.contains(group) {
                let realmSavedGroup = RealmSavedGroup(group: group)
                self.saveGroupsToRealm([realmSavedGroup])
            }
            //self.tableView.reloadData()
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(
            UINib(nibName: "ImageCell", bundle: nil),
            forCellReuseIdentifier: "imageCell")
        
        do {
            self.realmGroupResults = try RealmService.load(typeOf: RealmSavedGroup.self)
            guard let realmGroups = self.realmGroupResults else { return }
            groups = realmGroups.map { Group(id: $0.id, title: $0.title, imageURL: $0.groupPhotoURL) }
        } catch {
            print(error)
        }
        
        groupToken = realmGroupResults?.observe({ [weak self] groupChanges in
            guard let self = self else { return }
            switch groupChanges {
            case .initial(_):
                self.tableView.reloadData()
            case .update(_, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                print(deletions, insertions, modifications)
                self.tableView.beginUpdates()
                let deletionIndexPath = deletions.map { IndexPath(row: $0, section: 0) }
                let insertionIndexPath = insertions.map { IndexPath(row: $0, section: 0) }
                let modificateIndexPath = modifications.map { IndexPath(row: $0, section: 0) }
                self.tableView.deleteRows(at: deletionIndexPath, with: .fade)
                self.tableView.insertRows(at: insertionIndexPath, with: .automatic)
                self.tableView.reloadRows(at: modificateIndexPath, with: .automatic)
                self.tableView.endUpdates()
            case .error(let error):
                print(error)
            }
        })
    }
    
    deinit {
        groupToken?.invalidate()
    }
    
    // MARK: - Private methods
    
    private func saveGroupsToRealm(_ realmGroups: [RealmSavedGroup]) {
        do {
            try RealmService.save(items: realmGroups)
            let newGroups = realmGroups.map { Group($0) }
            groups.append(contentsOf: newGroups)
        } catch {
            print(error)
        }
    }
    
    private func deleteGroupFromRealm(_ realmGroup: RealmSavedGroup) {
        do {
            let group = Group(id: realmGroup.id, title: realmGroup.title, imageURL: realmGroup.groupPhotoURL)
            if let index = groups.firstIndex(of: group) {
                groups.remove(at: index)
            }
            try RealmService.delete(object: realmGroup)
        } catch {
            print(error)
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //guard let realmGroups = realmGroupResults else { return groups.count }
        //return realmGroups.count
        return groups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as? ImageCell
        else { return UITableViewCell() }
        
        let currentGroup = groups[indexPath.row]
        cell.configureCell(
            label: currentGroup.title,
            additionalLabel: nil,
            pictureURL: currentGroup.groupPictureURL,
            color: currentGroup.codeColor)
        
        return cell
    }

    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let group = groups[indexPath.row]
            guard let realmGroup = realmGroupResults?.first(where: { $0.id == group.id }) else { return }
            deleteGroupFromRealm(realmGroup)
        }    
    }
    
    @IBAction func addGroup() {
        performSegue(withIdentifier: "addGroup", sender: nil)
    }
}
