//
//  SwitchItem.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 14/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class SwitchItem: GroupItem {

    var enabled = false
    var valueChanged: ((_ newValue: Bool) -> Void)?
    fileprivate weak var switchControl: UISwitch?

    init(title: String, enabled: Bool? = false) {
        self.enabled = enabled ?? false
        super.init(title: title, category: .boolean)
    }

    func bindSwitchControl(_ switchControl: UISwitch) {
        self.switchControl = switchControl
        self.switchControl?.addTarget(self, action: #selector(didChangeSwitchState(_: forEvents:)),
        for: .valueChanged)
    }

    func unbindSwitchControl() {
        switchControl?.removeTarget(self, action: #selector(didChangeSwitchState(_: forEvents:)),
        for: .valueChanged)
    }

    dynamic func didChangeSwitchState(_ sender: UISwitch, forEvents events: UIControlEvents) {
        enabled = sender.isOn
        valueChanged?(sender.isOn)
    }
}
