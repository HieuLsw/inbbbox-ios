//
//  SwitchCell.swift
//  Inbbbox
//
//  Created by Peter Bruz on 18/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class SwitchCell: UITableViewCell, Reusable {

    let switchControl = UISwitch.newAutoLayout()
    let titleLabel = UILabel.newAutoLayout()
    let edgesInset: CGFloat = 16

    fileprivate var didSetConstraints = false

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.font = UIFont.sanFransiscoFont(withType: .regular, size: 17)
        titleLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(titleLabel)

        switchControl.layer.cornerRadius = 18.0
        switchControl.thumbTintColor = UIColor.white
        switchControl.onTintColor = UIColor.pinkColor()
        contentView.addSubview(switchControl)

        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message: "Use init(style:reuseIdentifier:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        if !didSetConstraints {
            didSetConstraints = true

            titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: edgesInset)
            titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)

            switchControl.autoPinEdge(.leading, to: .trailing, of: titleLabel, withOffset: 5)
            switchControl.autoPinEdge(toSuperviewEdge: .trailing, withInset: edgesInset)
            switchControl.autoAlignAxis(toSuperviewAxis: .horizontal)
        }

        super.updateConstraints()
    }
}

extension SwitchCell: ColorModeAdaptable {
    func adaptColorMode(_ mode: ColorModeType) {
        titleLabel.textColor = mode.tableViewCellTextColor
        switchControl.tintColor = mode.switchCellTintColor
        switchControl.backgroundColor = switchControl.tintColor
    }
}
