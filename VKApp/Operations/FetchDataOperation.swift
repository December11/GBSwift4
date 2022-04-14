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
        guard
            let userID = VKWVLoginViewController.keychain.get("userID"),
            let accessToken = VKWVLoginViewController.keychain.get("accessToken")
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
                print("## 1. fetchedData.count = \(String(describing: self?.fetchedData?.count))")
                self?.state = .finished
            }
        }
    }
}
