//
//  LabelCell.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 19.02.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PureLayout

class LabelCell: UITableViewCell, Reusable {

    let titleLabel = UILabel.newAutoLayout()

    fileprivate var didSetConstraints = false

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.textColor = UIColor.pinkColor()
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)

        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message: "Use init(style:reuseIdentifier:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        if !didSetConstraints {
            didSetConstraints = true
            titleLabel.autoPinEdgesToSuperviewEdges()
        }

        super.updateConstraints()
    }
}

extension LabelCell: ColorModeAdaptable {
    func adaptColorMode(_ mode: ColorModeType) {
        selectedBackgroundView = UIView.withColor(mode.settingsSelectedCellBackgound)
    }
}
