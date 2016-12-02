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

    let datePicker = UIDatePicker.newAutoLayout()
    fileprivate let contentView = UIView.newAutoLayout()
    fileprivate let separatorLine = UIView.newAutoLayout()

    fileprivate var didSetConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        let currentMode = ColorModeProvider.current()
        backgroundColor = currentMode.datePickerViewBackgroundColor

        contentView.backgroundColor = currentMode.datePickerBackgroundColor
        addSubview(contentView)

        datePicker.backgroundColor = currentMode.datePickerBackgroundColor
        datePicker.setValue(currentMode.datePickerTextColor, forKey: "textColor")
        datePicker.datePickerMode = .time
        contentView.addSubview(datePicker)

        separatorLine.backgroundColor = currentMode.datePickerViewSeparatorColor
        contentView.addSubview(separatorLine)

        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message: "Use init(frame:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didSetConstraints {
            didSetConstraints = true

            contentView.autoAlignAxis(toSuperviewAxis: .vertical)
            contentView.autoMatch(.width, to: .width, of: self)
            contentView.autoSetDimension(.height, toSize: 217)
            contentView.autoPinEdge(toSuperviewEdge: .top)

            datePicker.autoCenterInSuperview()
            datePicker.autoMatch(.width, to: .width, of: contentView)
            datePicker.autoSetDimension(.height, toSize: 177)

            separatorLine.autoAlignAxis(toSuperviewAxis: .vertical)
            separatorLine.autoMatch(.width, to: .width, of: contentView)
            separatorLine.autoSetDimension(.height, toSize: 1)
            separatorLine.autoPinEdge(toSuperviewEdge: .bottom, withInset: -1)
        }

        super.updateConstraints()
    }
}
