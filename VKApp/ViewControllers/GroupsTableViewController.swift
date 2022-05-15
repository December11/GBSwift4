//
//  GroupsTableViewController.swift
//  VKApp
//
//  Created by Alla Shkolnik on 18.12.2021.
//

import RealmSwift
import UIKit

final class GroupsTableViewController: UITableViewController {
    
    private let groupsDataService = GroupsService.instance
    private var groupToken: NotificationToken?
    private var groups = [Group]()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == "addGroup",
            let allGroupsViewController = segue.destination as? AllGroupTableViewController
        else { return }
        allGroupsViewController.completion = { [weak self] group in
            guard let self = self else { return }
            if !self.groups.contains(group) {
                let realmGroup = RealmGroup(group: group)
                self.groups.append(group)
                let saveOperation = RealmSaveOperation(data: [realmGroup])
                OperationQueue.main.addOperation(saveOperation)
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(for: ImageCell.self)
        do {
            if let fetchedData = try groupsDataService.getGroups() {
                groups = fetchedData
            }
        } catch {
            print("## Error. Can't load groups from Realm or JSON", error)
        }
        
        groupToken = groupsDataService.realmResults?.observe({ [weak self] groupChanges in
            guard let self = self else { return }
            switch groupChanges {
            case .initial:
                self.tableView.reloadData()
            case .update:
                self.tableView.reloadData()
            case .error(let error):
                print("## Error. Can't reload groups tableView", error)
            }
        })
    }
    
    deinit {
        groupToken?.invalidate()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCell = tableView.dequeueReusableCell(for: indexPath)
        
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
            guard
                let realmGroups = groupsDataService.realmResults,
                let realmGroup = realmGroups.first(where: { $0.id == group.id }) else { return }
            self.groups.remove(at: indexPath.row)
            groupsDataService.deleteFromRealm(realmGroup)
        }    
    }
    
    @IBAction func addGroup() {
        performSegue(withIdentifier: "addGroup", sender: nil)
    }
}
