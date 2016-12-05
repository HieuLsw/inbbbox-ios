//
//  ShotDetailsDescriptionCollectionViewCell.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 19/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class ShotDetailsDescriptionCollectionViewCell: UICollectionViewCell {

    weak var delegate: UICollectionViewCellWithLabelContainingClickableLinksDelegate?

    private let descriptionLabel = TTTAttributedLabel.newAutoLayoutView()

    // Regards clickable links in description label
    private let layoutManager = NSLayoutManager()
    private let textContainer = NSTextContainer(size: CGSize.zero)
    lazy private var textStorage: NSTextStorage = {
        [unowned self] in
        return NSTextStorage(attributedString: self.descriptionLabel.attributedText ?? NSAttributedString())
    }()

    private let separatorView = UIView.newAutoLayoutView()
    private var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        descriptionLabel.numberOfLines = 0
        descriptionLabel.userInteractionEnabled = true
        descriptionLabel.linkAttributes = [NSForegroundColorAttributeName : UIColor.pinkColor()]
        contentView.addSubview(descriptionLabel)

        separatorView.backgroundColor = ColorModeProvider.current().shotDetailsSeparatorColor
        contentView.addSubview(separatorView)
    }

    @available(*, unavailable, message = "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let insets = self.dynamicType.contentInsets
        descriptionLabel.preferredMaxLayoutWidth = frame.size.width - insets.left - insets.right
        textContainer.size = descriptionLabel.bounds.size
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            let insets = self.dynamicType.contentInsets
            descriptionLabel.autoPinEdgesToSuperviewEdgesWithInsets(insets)

            separatorView.autoSetDimension(.Height, toSize: 1)
            separatorView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
        }

        super.updateConstraints()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        descriptionLabel.attributedText = nil
    }
}

// MARK: Regards clickable links in description label

extension ShotDetailsDescriptionCollectionViewCell {

    func setDescriptionLabelAttributedText(attributedText: NSAttributedString) {

        descriptionLabel.setText(attributedText)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = descriptionLabel.lineBreakMode
        textContainer.maximumNumberOfLines = descriptionLabel.numberOfLines

        descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                action: #selector(descriptionLabelDidTap(_:))))
    }

    func descriptionLabelDidTap(tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.labelContainingClickableLinksDidTap(tapGestureRecognizer, textContainer: textContainer,
                layoutManager: layoutManager)
    }
}

extension ShotDetailsDescriptionCollectionViewCell: AutoSizable {

    static var contentInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
}

extension ShotDetailsDescriptionCollectionViewCell: Reusable {

    class var reuseIdentifier: String {
        return String(ShotDetailsDescriptionCollectionViewCell)
    }
}
