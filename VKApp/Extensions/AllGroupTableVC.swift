//
//  AllGroupTableViewSearch.swift
//  VKApp
//
//  Created by Alla Shkolnik on 14.01.2022.
//

import UIKit

extension AllGroupTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let searchGroupsService = NetworkService<GroupDTO>()
        var searchedGroups = [Group]()
        
        //search groups
        searchGroupsService.path = "/method/groups.search"
        searchGroupsService.queryItems = [
            URLQueryItem(name: "user_id", value: String(SessionStorage.shared.userId)),
            URLQueryItem(name: "q", value: searchText),
            URLQueryItem(name: "access_token", value: SessionStorage.shared.token),
            URLQueryItem(name: "v", value: "5.131")
        ]
        
        searchGroupsService.fetch { groupsDTOObject in
            switch groupsDTOObject {
            case .failure(let error):
                print(error)
            case .success(let groupsDTO):
                groupsDTO.forEach { groupDTO in
                    searchedGroups.append(Group(id: groupDTO.id, title: groupDTO.title, imageURL: groupDTO.groupPhotoURL))
                }
                
                self.filteredGroups = searchText.isEmpty
                ? self.groups
                : self.filteredGroups.filter(
                    {(searchedGroup: Group) -> Bool in
                        return searchedGroup.title.range(of: searchText, options: .caseInsensitive) != nil
                    })
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
