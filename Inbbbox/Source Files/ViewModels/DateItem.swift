//
//  DateItem.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 14/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class DateItem: GroupItem {

    var date: Date
    var dateString: String { return dateFormatter.string(from: date) }

    var onValueChanged: ((_ date: Date) -> Void)?

    var highlighted = false

    init(title: String, date: Date? = Date()) {
        self.date = date ?? Date()

        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none

        super.init(title: title, category: .date)
    }

    fileprivate let dateFormatter = DateFormatter()
}

// MARK: Updatable

extension DateItem: Updatable {

    func update() {
        onValueChanged?(date)
    }
}
