//
//  GroupedListViewModel.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 14/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

protocol IndexPathsGettable {
    func indexPathsForItems(_ items: [GroupItem]) -> [IndexPath]?
    func indexPathsForItemOfType(_ itemType: GroupItem.Type) -> [IndexPath]?
}

class GroupedListViewModel: ListViewModel<GroupItem> {
    typealias T = GroupItem

    init(items: [[GroupItem]]) {
        super.init(sections: items.map { Section($0) })
    }

    required init(_ items: [T]) {
        fatalError("init has not been implemented")
    }

    required init(sections: [Section<T>]) {
        fatalError("init(sections:) has not been implemented")
    }
    
}

extension GroupedListViewModel: IndexPathsGettable {

    func indexPathsForItems(_ items: [GroupItem]) -> [IndexPath]? {
        var indexPaths: [IndexPath] = []

        itemize { (path, item) -> () in
            if items.contains(item) {
                indexPaths.append(IndexPath(row: path.row, section: path.section))
            }
        }

        return indexPaths.isEmpty ? nil : indexPaths
    }

    func indexPathsForItemOfType<T>(_ itemType: T.Type) -> [IndexPath]? {
        var indexPaths: [IndexPath] = []

        itemize { path, item in
            if item is T {
                indexPaths.append(IndexPath(row: path.row, section: path.section))
            }
        }
        return indexPaths.isEmpty ? nil : indexPaths
    }
}
