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
    fileprivate var didUpdateConstraints = false
    fileprivate let topInset = CGFloat(10)
    fileprivate let bottomInset = CGFloat(10)
    fileprivate let buttonSize = CGFloat(24)
    fileprivate var isEditing = true {
        didSet {
            deleteLabel.text = deleteLabelText
            let imageName = isEditing ? "ic-delete-comment" : "ic-report-comment"
            deleteButton.setImage(UIImage(named: imageName), for: .normal)
            likeButton.isHidden = isEditing
            likeLabel.isHidden = isEditing
            setUpConstraints()
        }
    }
    fileprivate var isLiked = false {
        didSet {
            let imageName = isLiked ? "ic-like-details-active" : "ic-like-details"
            likeButton.setImage(UIImage(named: imageName), for: .normal)
        }
    }

    fileprivate var deleteLabelText: String {
        if isEditing {
            return NSLocalizedString("CommentEditView.Delete", comment: "Editing comment, delete.")
        } else {
            return NSLocalizedString("CommentEditView.Report", comment: "Editing comment, report content")
        }
    }

    // Colors
    fileprivate let viewBackgroundColor = UIColor.clear

    // public UI Components
    let likeButton = UIButton()
    let likeLabel = UILabel()
    let cancelButton = UIButton()
    let cancelLabel = UILabel()
    let deleteButton = UIButton()
    let deleteLabel = UILabel()
    let contentView: UIView = {
        if Settings.Customization.CurrentColorMode == .nightMode {
            return UIView.withColor(ColorModeProvider.current().shotDetailsCommentCollectionViewCellBackground)
        } else {
            return UIVisualEffectView(effect: UIBlurEffect(style: .light))
        }
    }()

    // MARK: Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = viewBackgroundColor
        setupSubviews()
    }

    @available(*, unavailable, message: "Use init(frame: CGRect) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UI

    override class var requiresConstraintBasedLayout: Bool {
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

            likeButton.autoAlignAxis(.horizontal, toSameAxisOf: likeButton.superview!,
                withOffset: buttonsCenterOffset)
            likeButton.autoAlignAxis(.vertical, toSameAxisOf: likeButton.superview!,
                withOffset: -(distanceBetweenButtons + buttonSize))
            likeButton.autoSetDimensions(to: CGSize(width: buttonSize, height: buttonSize))

            likeLabel.autoAlignAxis(.horizontal, toSameAxisOf: likeButton,
                withOffset: buttonSize / 2 + buttonsToLabelsAdditionalOffset)
            likeLabel.autoAlignAxis(.vertical, toSameAxisOf: likeButton)

            deleteButton.autoAlignAxis(.horizontal, toSameAxisOf: deleteButton.superview!,
                withOffset: buttonsCenterOffset)
            deleteButton.autoAlignAxis(.vertical, toSameAxisOf: deleteButton.superview!,
                withOffset: deleteButtonOffset)
            deleteButton.autoSetDimensions(to: CGSize(width: buttonSize, height: buttonSize))

            deleteLabel.autoAlignAxis(.horizontal, toSameAxisOf: deleteButton,
                withOffset: buttonSize / 2 + buttonsToLabelsAdditionalOffset)
            deleteLabel.autoAlignAxis(.vertical, toSameAxisOf: deleteButton)

            cancelButton.autoAlignAxis(.horizontal, toSameAxisOf: deleteButton)
            cancelButton.autoAlignAxis(.vertical, toSameAxisOf: cancelButton.superview!,
                withOffset: cancelButtonOffset)
            cancelButton.autoSetDimensions(to: CGSize(width: buttonSize, height: buttonSize))

            cancelLabel.autoAlignAxis(.horizontal, toSameAxisOf: deleteLabel)
            cancelLabel.autoAlignAxis(.vertical, toSameAxisOf: cancelButton)

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

    fileprivate func setupSubviews() {
        setupBlurView()
        setupCancelButton()
        setupDeleteButton()
        setupLikeButton()
        setupCancelLabel()
        setupDeleteLabel()
        setupLikeLabel()
    }

    fileprivate func setupBlurView() {

        addSubview(contentView)
    }

    fileprivate func setupCancelButton() {
        cancelButton.setImage(UIImage(named: "ic-cancel-comment"), for: .normal)
        cancelButton.contentMode = .scaleAspectFit
        contentView.addSubview(cancelButton)
    }

    fileprivate func setupDeleteButton() {
        deleteButton.setImage(UIImage(named: "ic-delete-comment"), for: .normal)
        deleteButton.contentMode = .scaleAspectFit
        contentView.addSubview(deleteButton)
    }

    fileprivate func setupLikeButton() {
        likeButton.setImage(UIImage(named: "ic-like-details"), for: .normal)
        likeButton.contentMode = .scaleAspectFit
        contentView.addSubview(likeButton)
    }

    fileprivate func setupCancelLabel() {
        cancelLabel.font = UIFont.sanFransiscoFont(withType: .regular, size: 10)
        cancelLabel.textColor = ColorModeProvider.current().shotDetailsCommentEditLabelTextColor
        cancelLabel.text = NSLocalizedString("CommentEditView.Cancel", comment: "Cancel editing comment.")
        contentView.addSubview(cancelLabel)
    }

    fileprivate func setupDeleteLabel() {
        deleteLabel.font = UIFont.sanFransiscoFont(withType: .regular, size: 10)
        deleteLabel.textColor = ColorModeProvider.current().shotDetailsCommentEditLabelTextColor
        deleteLabel.text = deleteLabelText
        contentView.addSubview(deleteLabel)
    }

    fileprivate func setupLikeLabel() {
        likeLabel.font = UIFont.sanFransiscoFont(withType: .regular, size: 10)
        likeLabel.textColor = ColorModeProvider.current().shotDetailsCommentEditLabelTextColor
        likeLabel.text = NSLocalizedString("CommentEditView.Like",
                                           comment: "Mark selected comment as liked.")
        contentView.addSubview(likeLabel)
    }
}
