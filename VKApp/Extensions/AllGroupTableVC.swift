//
//  AllGroupTableViewSearch.swift
//  VKApp
//
//  Created by Alla Shkolnik on 14.01.2022.
//

import UIKit

extension AllGroupTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filteredGroups.removeAll()
        
        let queryInterval = 1.0
        Timer.scheduledTimer(withTimeInterval: queryInterval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.fetchSearchedGroupsFromJSON(by: searchText)
        }
    }
        
    func fetchSearchedGroupsFromJSON(by searchText: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let groupsService = NetworkService<GroupDTO>()
            groupsService.path = "/method/groups.search"
            groupsService.queryItems = [
                URLQueryItem(name: "q", value: searchText),
                URLQueryItem(name: "type", value: "group"),
                URLQueryItem(name: "access_token", value: SessionStorage.shared.token),
                URLQueryItem(name: "v", value: "5.131")
            ]
            groupsService.fetch { [weak self] searchedGroupsDTO in
                switch searchedGroupsDTO {
                case .failure(let error):
                    print("## Error. Can't load search group results from JSON", error)
                case .success(let searchedGroupsDTO):
                    self?.filteredGroups = searchedGroupsDTO.map {
                        Group(id: $0.id ?? 0, title: $0.title ?? "Anonymous group", imageURL: $0.groupPhotoURL)
                    }
                }
            }
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
