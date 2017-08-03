//
//  CollectionExtension.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 30/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

extension Collection {

    /// Shuffle CollectionType.
    ///
    /// - returns: Same collection with random order of elements.
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

private extension MutableCollection where Index == Int {
    mutating func shuffleInPlace() {
        if count < 2 { return }

        for i in 0 ..< UInt32(count.toIntMax()) - 1 {
            let d = UInt32(count.toIntMax()) - i
            let random = arc4random_uniform(UInt32(d))
            let j = UInt32(random + i)
            guard i != j else { continue }
            swap(&self[Int(i)], &self[Int(j)])
        }
    }
}
