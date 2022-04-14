//
//  RealmInitiable.swift
//  VKApp
//
//  Created by Alla Shkolnik on 07.04.2022.
//

import UIKit

protocol DTOInitiable {
    associatedtype TypeDTO: Decodable
    init(fromDTO: TypeDTO)
}
