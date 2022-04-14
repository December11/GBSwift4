//
//  GetDataOperation.swift
//  VKApp
//
//  Created by Alla Shkolnik on 07.04.2022.
//

import UIKit

class FetchDataOperation: AsyncOperation {
    private var request: NetworkService<GroupDTO>
    var fetchedData: [GroupDTO]?
    
    override init() {
        self.request = NetworkService<GroupDTO>()
        self.request.path = "/method/groups.get"
        self.request.queryItems = [
            URLQueryItem(name: "user_id", value: String(SessionStorage.shared.userId)),
            URLQueryItem(name: "extended", value: "1"),
            URLQueryItem(name: "fields", value: "description"),
            URLQueryItem(name: "access_token", value: SessionStorage.shared.token),
            URLQueryItem(name: "v", value: "5.131")
        ]
    }
    
    override func main() {
        self.request.fetch { [weak self] fetchResult in
            switch fetchResult {
            case .failure(let error): print(error)
            case .success(let dataDTO):
                self?.fetchedData = dataDTO.compactMap { $0 }
                self?.state = .finished
            }
        }
    }
}
