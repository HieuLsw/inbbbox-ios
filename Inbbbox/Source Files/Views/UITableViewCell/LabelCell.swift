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

    class var reuseIdentifier: String {
        return "TableViewLabelCellReuseIdentifier"
    }

    let titleLabel = UILabel.newAutoLayoutView()

    private var didSetConstraints = false

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.textColor = UIColor.pinkColor()
        titleLabel.textAlignment = .Center
        contentView.addSubview(titleLabel)

        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message="Use init(style:reuseIdentifier:) method instead")
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
    func adaptColorMode(mode: ColorModeType) {
        selectedBackgroundView = UIView.withColor(mode.settingsSelectedCellBackgound)
    }
}
