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
        let authService = AuthService.shared
        self.request = NetworkService<GroupDTO>()
        guard
            let userID = authService.keychain.get("userID"),
            let accessToken = authService.keychain.get("accessToken")
        else { return }
        
        self.request.path = "/method/groups.get"
        self.request.queryItems = [
            URLQueryItem(name: "user_id", value: userID),
            URLQueryItem(name: "extended", value: "1"),
            URLQueryItem(name: "fields", value: "description"),
            URLQueryItem(name: "access_token", value: accessToken),
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
