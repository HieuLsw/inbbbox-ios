//
//  Cache.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct SharedCache {
    static var likedShots: Cache<LikedShot> {
        struct Static {
            static let cache = Cache<LikedShot>()
        }
        return Static.cache
    }
}

final class Cache<T> where T:Hashable, T:Sortable {

    private var elements = Set<T>()

    /// Returns number of items.
    var count: Int {
        return elements.count
    }

    /// Appends element to cache. Replaces duplicate, if any.
    /// - parameter element: Element to append.
    func add(_ element: T) {
        elements.update(with: element)
    }

    /// Adds contents of array to cache. Replaces duplicates, if any.
    /// - parameter elements: Array to add.
    func add(_ elements: [T]) {
        elements.forEach { self.elements.update(with: $0) }
    }

    /// Returns all elements, sorted by `createdAt`, descending.
    /// - returns: All elements.
    func all() -> [T] {
        return elements.sorted { $0.createdAt.compare($1.createdAt as Date) == .orderedDescending }
    }

    /// Removes single element
    /// - parameter element: Element to remove.
    func remove(_ element: T) {
        elements.remove(element)
    }

    /// Removes all elements
    func removeAll() {
        elements.removeAll()
    }
}
