//
//  EmptyDataSetView.swift
//  Inbbbox
//
//  Created by Peter Bruz on 23/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class EmptyDataSetView: UIView {

    fileprivate let descriptionLabel = UILabel.newAutoLayout()
    fileprivate let imageView = UIImageView.newAutoLayout()

    fileprivate var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.image = UIImage(named: "logo-empty")
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)

        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        addSubview(descriptionLabel)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            imageView.autoAlignAxis(toSuperviewAxis: .vertical)
            imageView.autoAlignAxis(.horizontal, toSameAxisOf: imageView.superview!, withOffset: -90)
            imageView.autoSetDimensions(to: CGSize(width: 140, height: 140))

            descriptionLabel.autoAlignAxis(toSuperviewAxis: .vertical)
            descriptionLabel.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: 40)
            descriptionLabel.autoPinEdge(toSuperviewMargin: .leading)
            descriptionLabel.autoPinEdge(toSuperviewMargin: .trailing)
        }
        super.updateConstraints()
    }

    func setDescriptionText(firstLocalizedString: String, attachmentImage: UIImage?,
                            imageOffset: CGPoint, lastLocalizedString: String) {

        descriptionLabel.attributedText = {
            let compoundAttributedString = NSMutableAttributedString.emptyDataSetStyledString(firstLocalizedString)
            let textAttachment: NSTextAttachment = NSTextAttachment()
            textAttachment.image = attachmentImage
            if let image = textAttachment.image {
                textAttachment.bounds = CGRect(origin: imageOffset, size: image.size)
            }
            let attributedStringWithImage: NSAttributedString = NSAttributedString(attachment: textAttachment)
            compoundAttributedString.append(attributedStringWithImage)
            let lastAttributedString = NSMutableAttributedString.emptyDataSetStyledString(lastLocalizedString)
            compoundAttributedString.append(lastAttributedString)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            compoundAttributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle,
                    range: NSRange(location: 0, length: compoundAttributedString.length))

            return compoundAttributedString
        }()
    }
}
