//
//  Date.swift
//  VKApp
//
//  Created by Alla Shkolnik on 15.01.2022.
//

import Foundation

extension Date {
    enum DateFormat: String {
        case dateTime = "dd.MM.yy, HH:mm"
        case date = "dd.MM.yy"
        case dateTimeZone = "yyyy-MM-dd HH:mm:ss Z"
    }
    
    func toString(dateFormat: DateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.rawValue
        return dateFormatter.string(from: self)
    }
    
    var unixString: String? {
        return self.timeIntervalSince1970.description
    }
}
