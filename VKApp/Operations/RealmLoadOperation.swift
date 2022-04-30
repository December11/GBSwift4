//
//  LoadRealmData.swift
//  VKApp
//
//  Created by Alla Shkolnik on 09.04.2022.
//

import RealmSwift

final class RealmLoadOperation: AsyncOperation {
    private(set) var realmResults: Results<RealmGroup>?
    
    init(data: Results<RealmGroup>?) {
        if let data = data {
            self.realmResults = data
        } else {
            do {
                self.realmResults = try RealmService.load(typeOf: RealmGroup.self)
            } catch {
                print("## Error. Can't load data from Realm")
            }
        }
    }
    
    override func main() {
        if isCancelled {
            return
        }
        self.state = .finished
    }
}
