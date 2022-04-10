//
//  LoadRealmData.swift
//  VKApp
//
//  Created by Alla Shkolnik on 09.04.2022.
//

import Foundation
import RealmSwift

final class RealmLoadOperation: AsyncOperation {
    private(set) var realmResults: Results<RealmGroup>?
    
    override init() { }
    
    override func main() {
        guard let realmData = dependencies.first as? RealmSaveOperation? else {
            print("## Error. can't check dependencies")
            return
        }
        self.realmResults = realmData?.realmResults
        self.state = .finished
    }
}
