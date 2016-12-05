//
//  CommentEditView.swift
//  Inbbbox
//
//  Created by Peter Bruz on 15/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class CommentEditView: UIView {

    // Private Properties
    private var didUpdateConstraints = false
    private let topInset = CGFloat(10)
    private let bottomInset = CGFloat(10)
    private let buttonSize = CGFloat(24)
    private var isEditing = true {
        didSet {
            deleteLabel.text = deleteLabelText
            let imageName = isEditing ? "ic-delete-comment" : "ic-report-comment"
            deleteButton.setImage(UIImage(named: imageName), forState: .Normal)
            likeButton.hidden = isEditing
            likeLabel.hidden = isEditing
            setUpConstraints()
        }
    }
    private var isLiked = false {
        didSet {
            let imageName = isLiked ? "ic-like-details-active" : "ic-like-details"
            likeButton.setImage(UIImage(named: imageName), forState: .Normal)
        }
    }

    private var deleteLabelText: String {
        if isEditing {
            return NSLocalizedString("CommentEditView.Delete", comment: "Editing comment, delete.")
        } else {
            return NSLocalizedString("CommentEditView.Report", comment: "Editing comment, report content")
        }
    }

    // Colors
    private let viewBackgroundColor = UIColor.clearColor()

    // public UI Components
    let likeButton = UIButton()
    let likeLabel = UILabel()
    let cancelButton = UIButton()
    let cancelLabel = UILabel()
    let deleteButton = UIButton()
    let deleteLabel = UILabel()
    let contentView: UIView = {
        if Settings.Customization.CurrentColorMode == .NightMode {
            return UIView.withColor(ColorModeProvider.current().shotDetailsCommentCollectionViewCellBackground)
        } else {
            return UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        }
    }()

    // MARK: Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = viewBackgroundColor
        setupSubviews()
    }

    @available(*, unavailable, message = "Use init(frame: CGRect) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UI

    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }

    func setUpConstraints() {
        let distanceBetweenButtons = CGFloat(60)
        let buttonsCenterOffset = CGFloat(-5)
        let buttonsToLabelsAdditionalOffset = CGFloat(10)
        var deleteButtonOffset = -(distanceBetweenButtons / 2 + buttonSize / 2)
        var cancelButtonOffset = distanceBetweenButtons / 2 + buttonSize / 2
        if !isEditing {
            deleteButtonOffset = 0
            cancelButtonOffset = distanceBetweenButtons + buttonSize
        }

        if !didUpdateConstraints {

            contentView.autoPinEdgesToSuperviewEdges()

            likeButton.autoAlignAxis(.Horizontal, toSameAxisOfView: likeButton.superview!,
                withOffset: buttonsCenterOffset)
            likeButton.autoAlignAxis(.Vertical, toSameAxisOfView: likeButton.superview!,
                withOffset: -(distanceBetweenButtons + buttonSize))
            likeButton.autoSetDimensionsToSize(CGSize(width: buttonSize, height: buttonSize))

            likeLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: likeButton,
                withOffset: buttonSize / 2 + buttonsToLabelsAdditionalOffset)
            likeLabel.autoAlignAxis(.Vertical, toSameAxisOfView: likeButton)

            deleteButton.autoAlignAxis(.Horizontal, toSameAxisOfView: deleteButton.superview!,
                withOffset: buttonsCenterOffset)
            deleteButton.autoAlignAxis(.Vertical, toSameAxisOfView: deleteButton.superview!,
                withOffset: deleteButtonOffset)
            deleteButton.autoSetDimensionsToSize(CGSize(width: buttonSize, height: buttonSize))

            deleteLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: deleteButton,
                withOffset: buttonSize / 2 + buttonsToLabelsAdditionalOffset)
            deleteLabel.autoAlignAxis(.Vertical, toSameAxisOfView: deleteButton)

            cancelButton.autoAlignAxis(.Horizontal, toSameAxisOfView: deleteButton)
            cancelButton.autoAlignAxis(.Vertical, toSameAxisOfView: cancelButton.superview!,
                withOffset: cancelButtonOffset)
            cancelButton.autoSetDimensionsToSize(CGSize(width: buttonSize, height: buttonSize))

            cancelLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: deleteLabel)
            cancelLabel.autoAlignAxis(.Vertical, toSameAxisOfView: cancelButton)

            didUpdateConstraints = true
        }
    }

    // MARK: Public
    func configureForEditing() {
        isEditing = true
    }

    func configureForReporting() {
        isEditing = false
    }

    func setLiked(withValue value: Bool) {
        isLiked = value
    }

    // MARK: Private

    private func setupSubviews() {
        setupBlurView()
        setupCancelButton()
        setupDeleteButton()
        setupLikeButton()
        setupCancelLabel()
        setupDeleteLabel()
        setupLikeLabel()
    }

    private func setupBlurView() {

        addSubview(contentView)
    }

    private func setupCancelButton() {
        cancelButton.setImage(UIImage(named: "ic-cancel-comment"), forState: .Normal)
        cancelButton.contentMode = .ScaleAspectFit
        contentView.addSubview(cancelButton)
    }

    private func setupDeleteButton() {
        deleteButton.setImage(UIImage(named: "ic-delete-comment"), forState: .Normal)
        deleteButton.contentMode = .ScaleAspectFit
        contentView.addSubview(deleteButton)
    }

    private func setupLikeButton() {
        likeButton.setImage(UIImage(named: "ic-like-details"), forState: .Normal)
        likeButton.contentMode = .ScaleAspectFit
        contentView.addSubview(likeButton)
    }

    private func setupCancelLabel() {
        cancelLabel.font = UIFont.helveticaFont(.Neue, size: 10)
        cancelLabel.textColor = ColorModeProvider.current().shotDetailsCommentEditLabelTextColor
        cancelLabel.text = NSLocalizedString("CommentEditView.Cancel", comment: "Cancel editing comment.")
        contentView.addSubview(cancelLabel)
    }

    private func setupDeleteLabel() {
        deleteLabel.font = UIFont.helveticaFont(.Neue, size: 10)
        deleteLabel.textColor = ColorModeProvider.current().shotDetailsCommentEditLabelTextColor
        deleteLabel.text = deleteLabelText
        contentView.addSubview(deleteLabel)
    }

    private func setupLikeLabel() {
        likeLabel.font = UIFont.helveticaFont(.Neue, size: 10)
        likeLabel.textColor = ColorModeProvider.current().shotDetailsCommentEditLabelTextColor
        likeLabel.text = NSLocalizedString("CommentEditView.Like",
                                           comment: "Mark selected comment as liked.")
        contentView.addSubview(likeLabel)
    }
}
