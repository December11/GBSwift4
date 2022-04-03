//
//  AllGroupTableViewController.swift
//  VKApp
//
//  Created by Alla Shkolnik on 18.12.2021.
//

import UIKit
import RealmSwift

class AllGroupTableViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!

    private let groupsDataService = GroupsService.instance
    var groups = [Group]()
    private var groupToken: NotificationToken?
    var filteredGroups = [Group]()
    var completion: ((Group) -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.placeholder = "Search some group"
        
        tableView.register(
            UINib(nibName: "ImageCell", bundle: nil),
            forCellReuseIdentifier: "imageCell")
        
        do {
            if let fetchedData = try groupsDataService.getData() {
                groups = fetchedData
            }
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupToken = groupsDataService.realmGroupResults?.observe({ [weak self] groupChanges in
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
        groupToken?.invalidate()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as? ImageCell
        else { return UITableViewCell() }
            
        let currentGroup = groups[indexPath.row]
            cell.configureCell(label: currentGroup.title, additionalLabel: nil, pictureURL: currentGroup.groupPictureURL, color: currentGroup.codeColor)
            
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentGroup = groups[indexPath.row]
        completion?(currentGroup)
        navigationController?.popViewController(animated: true)
    }
}
