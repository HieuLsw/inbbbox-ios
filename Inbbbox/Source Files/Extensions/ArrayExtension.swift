//
//  ArrayExtension.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 27/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

extension Array where Element : Equatable {

    /// Returns Array with unique elements.
    /// Contents of Array must conform to `Equatable` protocol.
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
    
    /// Removes element from array if element is in array.
    /// Contents of Array must conform to `Equatable` protocol.
    mutating func remove(ifContains element: Element) {
        if let i = index(of: element) {
            remove(at: i)
        }
    }
    
    
}
