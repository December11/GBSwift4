//
//  NetworkService.swift
//  VKApp
//
//  Created by Alla Shkolnik on 12.02.2022.
//

import UIKit

final class NetworkService<ItemsType: Decodable> {
    
    let session = URLSession.shared
    let scheme = "https"
    let host = "api.vk.com"
    var path = "/method/user"
    var queryItems = [URLQueryItem]()
    
    // MARK: - Public methods
    func fetch(completion: @escaping (Result<[ItemsType], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var urlComponents: URLComponents {
                var components = URLComponents()
                components.scheme = self.scheme
                components.host = self.host
                components.path = self.path
                components.queryItems = self.queryItems
                return components
            }
            guard let url = urlComponents.url else { return }
            
            let task = self.session.dataTask(with: url) { data, response, error in
                guard
                    error == nil,
                    let data = data
                else { return }
                do {
                    let json = try JSONDecoder().decode(ResponseDTO<ItemsType>.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(json.response.items))
                    }
                } catch {
                    print(error)
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
            task.resume()
        }
    }
}
