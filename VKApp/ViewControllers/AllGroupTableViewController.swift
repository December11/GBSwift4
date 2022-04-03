//
//  AllGroupTableViewController.swift
//  VKApp
//
//  Created by Alla Shkolnik on 18.12.2021.
//

import RealmSwift
import UIKit

class AllGroupTableViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var groupsDataService = GroupsService.instance
    var filteredGroups = [Group]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var completion: ((Group) -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.placeholder = "Search some group"
        
        tableView.register(for: ImageCell.self)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredGroups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageCell = tableView.dequeueReusableCell(for: indexPath)
        let currentGroup = filteredGroups[indexPath.row]
        cell.configureCell(
            label: currentGroup.title,
            additionalLabel: nil,
            pictureURL: currentGroup.groupPictureURL,
            color: currentGroup.codeColor
        )
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentGroup = filteredGroups[indexPath.row]
        completion?(currentGroup)
        navigationController?.popViewController(animated: true)
    }
}
