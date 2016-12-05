//
//  SwitchCell.swift
//  Inbbbox
//
//  Created by Peter Bruz on 18/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell, Reusable {

    class var reuseIdentifier: String {
        return "TableViewSwitchCellReuseIdentifier"
    }

    let switchControl = UISwitch.newAutoLayoutView()
    let titleLabel = UILabel.newAutoLayoutView()
    let edgesInset: CGFloat = 16

    private var didSetConstraints = false

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.font = UIFont.systemFontOfSize(17, weight: UIFontWeightRegular)
        titleLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(titleLabel)

        switchControl.layer.cornerRadius = 18.0
        switchControl.thumbTintColor = UIColor.whiteColor()
        switchControl.onTintColor = UIColor.pinkColor()
        contentView.addSubview(switchControl)

        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message="Use init(style:reuseIdentifier:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        if !didSetConstraints {
            didSetConstraints = true

            titleLabel.autoPinEdgeToSuperviewEdge(.Leading, withInset: edgesInset)
            titleLabel.autoAlignAxisToSuperviewAxis(.Horizontal)

            switchControl.autoPinEdge(.Leading, toEdge: .Trailing, ofView: titleLabel, withOffset: 5)
            switchControl.autoPinEdgeToSuperviewEdge(.Trailing, withInset: edgesInset)
            switchControl.autoAlignAxisToSuperviewAxis(.Horizontal)
        }

        super.updateConstraints()
    }
}

extension SwitchCell: ColorModeAdaptable {
    func adaptColorMode(mode: ColorModeType) {
        titleLabel.textColor = mode.tableViewCellTextColor
        switchControl.tintColor = mode.switchCellTintColor
        switchControl.backgroundColor = switchControl.tintColor
    }
}
