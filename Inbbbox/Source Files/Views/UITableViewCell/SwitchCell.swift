//
//  SwitchCell.swift
//  Inbbbox
//
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

        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightRegular)
        titleLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(titleLabel)

        switchControl.layer.cornerRadius = 16
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
            titleLabel.autoPinEdge(.trailing, to: .leading, of: switchControl, withOffset: -5)

            switchControl.autoSetDimensions(to: CGSize(width: 49, height: 31))
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
