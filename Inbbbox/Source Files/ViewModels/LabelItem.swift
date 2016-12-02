//
//  File.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 19.02.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

class LabelItem: GroupItem {

    var highlighted = false
    var onSelect: (() -> Void)?

    init(title: String) {
        super.init(title: title, category: .string)
    }
}
