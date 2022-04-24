//
//  FuturePromise.swift
//  VKApp
//
//  Created by Alla Shkolnik on 15.04.2022.
//

import Foundation

class Future<T> {
    fileprivate var result: Result<T, Error>? {
        didSet {
            guard let result = result else { return }
            callbacks.forEach { $0(result) }
        }
    }
    private var callbacks = [((Result<T, Error>) -> Void)]()
    
    func add(callback: @escaping ((Result<T, Error>) -> Void)) {
        callbacks.append(callback)
        result.map(callback)
    }
}

class Promise<T>: Future<T> {
    init(value: T? = nil) {
        super.init()
        result = value.map(Result.success)
    }
    
    func fulfill(with value: T) {
        result = .success(value)
    }
    func reject(with error: Error) {
        result = .failure(error)
    }
}
