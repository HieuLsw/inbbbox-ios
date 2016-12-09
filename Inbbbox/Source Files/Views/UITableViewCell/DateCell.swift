//
//  DateCell.swift
//  Inbbbox
//
//  Created by Peter Bruz on 18/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

class DateCell: UITableViewCell, Reusable {

    let dateLabel = UILabel.newAutoLayout()
    let titleLabel = UILabel.newAutoLayout()

    fileprivate var didSetConstraints = false

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessoryType = .disclosureIndicator

        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightRegular)
        titleLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(titleLabel)

        dateLabel.textColor = UIColor.followeeTextGrayColor()
        dateLabel.textAlignment = .right
        contentView.addSubview(dateLabel)

        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message: "Use init(style:reuseIdentifier:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        if !didSetConstraints {
            didSetConstraints = true

            titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
            titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)

            dateLabel.autoPinEdge(.leading, to: .trailing, of: titleLabel, withOffset: 5)
            dateLabel.autoPinEdge(toSuperviewEdge: .trailing)
            dateLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 12)
        }

        super.updateConstraints()
    }

    func setDateText(_ text: String) {
        dateLabel.text = text
    }
}

extension DateCell: ColorModeAdaptable {
    func adaptColorMode(_ mode: ColorModeType) {
        titleLabel.textColor = mode.tableViewCellTextColor
        selectedBackgroundView = UIView.withColor(mode.settingsSelectedCellBackgound)
    }
}
