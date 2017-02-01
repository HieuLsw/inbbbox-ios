//
//  DetailsCell.swift
//  Inbbbox
//
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

class DetailsCell: UITableViewCell, Reusable {

    let detailLabel = UILabel.newAutoLayout()
    let titleLabel = UILabel.newAutoLayout()

    fileprivate var didSetConstraints = false

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessoryType = .disclosureIndicator

        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightRegular)
        titleLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(titleLabel)

        detailLabel.textColor = UIColor.followeeTextGrayColor()
        detailLabel.textAlignment = .right
        contentView.addSubview(detailLabel)

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

            detailLabel.autoPinEdge(.leading, to: .trailing, of: titleLabel, withOffset: 5)
            detailLabel.autoPinEdge(toSuperviewEdge: .trailing)
            detailLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 12)
        }

        super.updateConstraints()
    }

    func setDetailText(_ text: String) {
        detailLabel.text = text
    }
}

extension DetailsCell: ColorModeAdaptable {
    func adaptColorMode(_ mode: ColorModeType) {
        titleLabel.textColor = mode.tableViewCellTextColor
        selectedBackgroundView = UIView.withColor(mode.settingsSelectedCellBackgound)
    }
}
