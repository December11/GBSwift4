//
//  GetDataOperation.swift
//  VKApp
//
//  Created by Alla Shkolnik on 07.04.2022.
//

import UIKit

class GetDataOperation: Operation {
    private var request: NetworkService<GroupDTO>
    var fetchedData: [RealmGroup]?
    
    init(request: NetworkService<GroupDTO>) {
        self.request = request
    }
    
    override func main() {
        DispatchQueue.global().async {
            self.request.fetch { [weak self] fetchResult in
                switch fetchResult {
                case .failure(let error): print(error)
                case .success(let dataDTO):
                    self?.fetchedData = dataDTO.map { RealmGroup(fromDTO: $0) }
                }
            }
        }
    }
}
