//
//  Cache.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct SharedCache {
    static var likedShots: Cache<Shot> {
        struct Static {
            static let cache = Cache<Shot>()
        }
        return Static.cache
    }
}

class Cache<T: Equatable> {

    /// Array containing elements.
    private(set) var elements = [T]()

    /// Appends element to cache. Removes duplicate, if any.
    /// - parameter element: Element to append.
    func append(_ element: T) {
        elements.remove(ifContains: element)
        elements.append(element)
    }

    /// Appends contents of array to cache. Removes duplicates, if any.
    /// - parameter elements: Array to append.
    func append(contentsOf elements: [T]) {
        elements.forEach { append($0) }
    }

    /// Adds contents of array to cache. Removes all elements before adding new ones.
    /// - parameter elements: Array to add.
    func add(_ elements: [T]) {
        removeAll()
        self.elements.append(contentsOf: elements)
    }

    /// Removes single element
    /// - parameter element: Element to remove.
    func remove(_ element: T) {
        elements = elements.filter { $0 != element }
    }

    /// Removes all elements
    func removeAll() {
        elements.removeAll()
    }
}
