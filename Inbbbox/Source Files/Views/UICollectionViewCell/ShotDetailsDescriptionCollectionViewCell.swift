//
//  ShotDetailsDescriptionCollectionViewCell.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 19/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class ShotDetailsDescriptionCollectionViewCell: UICollectionViewCell, Reusable {

    weak var delegate: UICollectionViewCellWithLabelContainingClickableLinksDelegate?

    fileprivate let descriptionLabel = TTTAttributedLabel.newAutoLayout()

    // Regards clickable links in description label
    fileprivate let layoutManager = NSLayoutManager()
    fileprivate let textContainer = NSTextContainer(size: CGSize.zero)
    lazy fileprivate var textStorage: NSTextStorage = {
        [unowned self] in
        return NSTextStorage(attributedString: self.descriptionLabel.attributedText ?? NSAttributedString())
    }()

    fileprivate let separatorView = UIView.newAutoLayout()
    fileprivate var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        descriptionLabel.numberOfLines = 0
        descriptionLabel.isUserInteractionEnabled = true
        descriptionLabel.linkAttributes = [NSForegroundColorAttributeName : UIColor.pinkColor()]
        contentView.addSubview(descriptionLabel)

        separatorView.backgroundColor = ColorModeProvider.current().shotDetailsSeparatorColor
        contentView.addSubview(separatorView)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let insets = type(of: self).contentInsets
        descriptionLabel.preferredMaxLayoutWidth = frame.size.width - insets.left - insets.right
        textContainer.size = descriptionLabel.bounds.size
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            let insets = type(of: self).contentInsets
            descriptionLabel.autoPinEdgesToSuperviewEdges(with: insets)

            separatorView.autoSetDimension(.height, toSize: 1)
            separatorView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .bottom)
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

    func setDescriptionLabelAttributedText(_ attributedText: NSAttributedString) {

        descriptionLabel.setText(attributedText)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = descriptionLabel.lineBreakMode
        textContainer.maximumNumberOfLines = descriptionLabel.numberOfLines

        descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                action: #selector(descriptionLabelDidTap(_:))))
    }

    func descriptionLabelDidTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.labelContainingClickableLinksDidTap(tapGestureRecognizer, textContainer: textContainer,
                layoutManager: layoutManager)
    }
}

extension ShotDetailsDescriptionCollectionViewCell: AutoSizable {

    static var contentInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
}
