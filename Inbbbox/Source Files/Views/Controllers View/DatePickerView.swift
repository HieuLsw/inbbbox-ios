//
//  DatePickerView.swift
//  Inbbbox
//
//  Created by Peter Bruz on 28/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

class DatePickerView: UIView {

    let datePicker = UIDatePicker.newAutoLayoutView()
    private let contentView = UIView.newAutoLayoutView()
    private let separatorLine = UIView.newAutoLayoutView()

    private var didSetConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        let currentMode = ColorModeProvider.current()
        backgroundColor = currentMode.datePickerViewBackgroundColor

        contentView.backgroundColor = currentMode.datePickerBackgroundColor
        addSubview(contentView)

        datePicker.backgroundColor = currentMode.datePickerBackgroundColor
        datePicker.setValue(currentMode.datePickerTextColor, forKey: "textColor")
        datePicker.datePickerMode = .Time
        contentView.addSubview(datePicker)

        separatorLine.backgroundColor = currentMode.datePickerViewSeparatorColor
        contentView.addSubview(separatorLine)

        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message="Use init(frame:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didSetConstraints {
            didSetConstraints = true

            contentView.autoAlignAxisToSuperviewAxis(.Vertical)
            contentView.autoMatchDimension(.Width, toDimension: .Width, ofView: self)
            contentView.autoSetDimension(.Height, toSize: 217)
            contentView.autoPinEdgeToSuperviewEdge(.Top)

            datePicker.autoCenterInSuperview()
            datePicker.autoMatchDimension(.Width, toDimension: .Width, ofView: contentView)
            datePicker.autoSetDimension(.Height, toSize: 177)

            separatorLine.autoAlignAxisToSuperviewAxis(.Vertical)
            separatorLine.autoMatchDimension(.Width, toDimension: .Width, ofView: contentView)
            separatorLine.autoSetDimension(.Height, toSize: 1)
            separatorLine.autoPinEdgeToSuperviewEdge(.Bottom, withInset: -1)
        }

        super.updateConstraints()
    }
}
