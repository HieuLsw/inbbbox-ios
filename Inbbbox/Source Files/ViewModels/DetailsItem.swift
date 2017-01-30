//
//  DetailsItem.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class DetailsItem: GroupItem {

    var detailString: String

    var highlighted = false

    init(title: String, detailString: String) {
        self.detailString = detailString

        super.init(title: title, category: .details)
    }
}
