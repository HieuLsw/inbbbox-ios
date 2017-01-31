//
//  GroupItem.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 14/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

protocol Updatable {
    func update()
}

class GroupItem: Equatable {

    enum Category {
        case details, date, boolean, string
    }

    var title: String
    let category: Category
    var active = true

    init(title: String, category: Category) {
        self.title = title
        self.category = category
    }
}

func == (lhs: GroupItem, rhs: GroupItem) -> Bool {
    return lhs.title == rhs.title && lhs.category == rhs.category && lhs.active == rhs.active
}
