//
//  String.swift
//  VKApp
//
//  Created by Alla Shkolnik on 04.01.2022.
//

import UIKit

extension String {
    var wordsCount: Int {
        var temp = self.count > 0 ? 1 : 0
        for symbol in self {
            if symbol == " " {
                temp += 1
            }
        }
        return temp
    }
    
    var acronym: String? {
        guard
            self.wordsCount != 0
        else { return nil }
        
        var abbrevation = ""
        if self.wordsCount == 1 {
            abbrevation += self.prefix(1)
            return abbrevation
        } else {
            let temp = self.split(separator: " ")
            for substring in temp
            where abbrevation.count < 2 {
                abbrevation += substring.prefix(1)
            }
        }
        return abbrevation.uppercased()
    }
    
    var bold: NSMutableAttributedString {
        let attributes = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)]
        return NSMutableAttributedString(string: self, attributes: attributes)
    }
}
