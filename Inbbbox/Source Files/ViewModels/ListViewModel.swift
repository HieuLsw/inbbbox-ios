//
//  ListViewModel.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 14/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation


typealias Path = (section: Int, row: Int)

protocol Itemizable {
    associatedtype T
    func itemize(_ closure: @escaping (_ path: Path, _ item: T) -> ())
}

protocol IndexPathOperatable {
    associatedtype T
    func addItem(_ item: T, atIndexPath indexPath: IndexPath)
    func removeAtIndexPath(_ indexPath: IndexPath)
    func removeItemsAtIndexPaths(_ indexPaths: [IndexPath])
}

class ListViewModel<T: Equatable> {

    var sections = List([Section<T>([])])

    required init(_ items: [T]) {
        sections = List([Section<T>(items)])
    }

    required init(sections: [Section<T>]) {
        self.sections = List(sections)
    }

    subscript(index: Int) -> List<T> {
        return sections[index]
    }

    subscript(index: Int) -> T? {
        return sections[0][index]
    }

    func sectionsCount() -> Int {
        return sections.count
    }
}

// MARK: Itemizable

extension ListViewModel: Itemizable {

    func itemize(_ closure: @escaping (_ path: Path, _ item: T) -> ()) {
        sections.itemize { section, item in
            item.itemize { closure((section, $0), $1) }
        }
    }
}

// MARK: IndexPathOperatable

extension ListViewModel: IndexPathOperatable {

    func getItemAtIndexPath(_ indexPath: IndexPath) -> T {
        return sections[indexPath.section][indexPath.row]
    }

    func addItem(_ item: T, atIndexPath indexPath: IndexPath) {
        sections[indexPath.section].add(item, atIndex: indexPath.row)
    }

    func removeAtIndexPath(_ indexPath: IndexPath) {
        sections[indexPath.section].remove(indexPath.row)
    }

    func removeItemsAtIndexPaths(_ indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            removeAtIndexPath(indexPath)
        }
    }
}

// MARK: Private

private extension ListViewModel {

    func sectionsFromItems<U: Equatable>(_ items: [T], byReadingValue readValue: @escaping (T) -> U) -> List<Section<T>>? {

        let values = items.map { readValue($0) }

        let sections: [Section<T>] = values.uniques.map { item in

            let section = Section(items.filter { item == readValue($0) })

            if let item = item as? StringConvertible {
                section.title = item.string()
            }
            return section
        }

        return List(sections)
    }
}

extension Array where Element: Equatable {

    var uniques: [Element] {
        var uniques = [Element]()
        for element in self {
            if !uniques.contains(element) {
                uniques.append(element)
            }
        }
        return uniques
    }
}
