//
//  FetchAnyDataOperation.swift
//  VKApp
//
//  Created by Alla Shkolnik on 24.04.2022.
//

final class FetchAnyDataOperation<FetchType: Decodable>: AsyncOperation {
    private var request: NetworkService<FetchType>
    var fetchedData: [FetchType]?
    var nextFrom = ""
    
    init(service: NetworkService<FetchType>) {
        self.request = service
    }
    
    override func main() {
        self.request.fetch { [weak self] fetchResult in
            switch fetchResult {
            case .failure(let error): print(error)
            case .success(let dataDTO):
                self?.fetchedData = dataDTO.compactMap { $0 }
                self?.nextFrom = self?.request.nextFrom ?? ""
                print("## FetchAnyDataOperation nextFrom = \(self?.nextFrom)")
                self?.state = .finished
            }
        }
    }
}
