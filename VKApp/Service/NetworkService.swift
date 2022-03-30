//
//  NetworkService.swift
//  VKApp
//
//  Created by Alla Shkolnik on 12.02.2022.
//

import Foundation
import UIKit

final class NetworkService<ItemsType: Decodable> {
    
    let session = URLSession.shared
    let scheme = "https"
    let host = "api.vk.com"
    var path = "/method/user"
    var queryItems = [URLQueryItem]()
    
    // MARK: - Public methods
    func fetch(completion: @escaping (Result<[ItemsType], Error>) -> Void) {
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = queryItems
            return components
        }
        guard let url = urlComponents.url else { return }
        
        let task = session.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                let data = data
            else { return }
            do{
                let json = try JSONDecoder().decode(ResponseDTO<ItemsType>.self, from: data)
                completion(.success(json.response.items))
            } catch {
                print(error)
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
//    func fetchSearched(for searchingText: String) {
//        self.queryItems.append(URLQueryItem(name: "q", value: searchingText))
//        fetch< { data in
//            guard data != nil else { return }
//        }
//    }
//
//    func fetchDataByField<ResponseType: Decodable>(by field: String, completion: @escaping (ResponseDTO<ResponseType>?) -> Void) {
//        fetch(completion: { data in
//            guard
//                let json = data,
//                let response = json["response"] as? [String: Any],
//                let items = response["items"] as? [[String: Any]]
//            else {
//                completion(nil)
//                return
//            }
//            let fieldValues = items.compactMap { dict in
//                dict[field] as? Int
//            }
//            completion(fieldValues)
//        }
//    })
}
