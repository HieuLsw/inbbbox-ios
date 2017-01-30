//
//  ORLoginLabel.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 29/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ORLoginLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)

        textAlignment = .center
        textColor = UIColor.RGBA(249, 212, 226, 1)
        font = UIFont.systemFont(ofSize: 11, weight: UIFontWeightMedium)
        text = Localized("ORLoginLabel.OR", comment: "Visible as a text allowing user to choose login method.")
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let boundingTextRect = text?.boundingRectWithFont(font!, constrainedToWidth: rect.width) ??
                CGRect.zero
        let space = CGFloat(10)
        let y = rect.midY

        let context = UIGraphicsGetCurrentContext()

        context?.setStrokeColor(textColor!.cgColor)
        context?.setLineWidth(1)

        context?.move(to: CGPoint(x: 0, y: y))
        context?.addLine(to: CGPoint(x: rect.midX - boundingTextRect.width * 0.5 - space, y: y))

        context?.move(to: CGPoint(x: rect.midX + boundingTextRect.width * 0.5 + space, y: y))
        context?.addLine(to: CGPoint(x: rect.maxX, y: y))

        context?.strokePath()
    }
}
