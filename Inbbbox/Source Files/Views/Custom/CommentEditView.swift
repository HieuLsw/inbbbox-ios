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
            updateDeleteButtonBasedOn(isEditing)
            updateLikeButtonBasedOn(isEditing)
            updateEditButtonBasedOn(isEditing)
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
    let editButton = UIButton()
    let editLabel = UILabel()
    
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

        if !didUpdateConstraints {

            contentView.autoPinEdgesToSuperviewEdges()

            likeButton.autoAlignAxis(.horizontal, toSameAxisOf: likeButton.superview!, withOffset: buttonsCenterOffset)
            likeButton.autoAlignAxis(.vertical, toSameAxisOf: likeButton.superview!, withOffset: -(distanceBetweenButtons + buttonSize))
            likeButton.autoSetDimensions(to: CGSize(width: buttonSize, height: buttonSize))

            likeLabel.autoAlignAxis(.horizontal, toSameAxisOf: likeButton, withOffset: buttonSize / 2 + buttonsToLabelsAdditionalOffset)
            likeLabel.autoAlignAxis(.vertical, toSameAxisOf: likeButton)

            deleteButton.autoAlignAxis(.horizontal, toSameAxisOf: deleteButton.superview!, withOffset: buttonsCenterOffset)
            deleteButton.autoAlignAxis(.vertical, toSameAxisOf: deleteButton.superview!)
            deleteButton.autoSetDimensions(to: CGSize(width: buttonSize, height: buttonSize))

            deleteLabel.autoAlignAxis(.horizontal, toSameAxisOf: deleteButton, withOffset: buttonSize / 2 + buttonsToLabelsAdditionalOffset)
            deleteLabel.autoAlignAxis(.vertical, toSameAxisOf: deleteButton)

            cancelButton.autoAlignAxis(.horizontal, toSameAxisOf: deleteButton, withOffset: buttonsCenterOffset)
            cancelButton.autoAlignAxis(.vertical, toSameAxisOf: cancelButton.superview!, withOffset: distanceBetweenButtons + buttonSize)
            cancelButton.autoSetDimensions(to: CGSize(width: buttonSize, height: buttonSize))

            cancelLabel.autoAlignAxis(.horizontal, toSameAxisOf: deleteLabel)
            cancelLabel.autoAlignAxis(.vertical, toSameAxisOf: cancelButton)
            
            editButton.autoAlignAxis(.horizontal, toSameAxisOf: editButton.superview!, withOffset: buttonsCenterOffset)
            editButton.autoAlignAxis(.vertical, toSameAxisOf: editButton.superview!, withOffset: -(distanceBetweenButtons + buttonSize))
            editButton.autoSetDimensions(to: CGSize(width: buttonSize, height: buttonSize))
            
            editLabel.autoAlignAxis(.horizontal, toSameAxisOf: editButton, withOffset: buttonSize / 2 + buttonsToLabelsAdditionalOffset)
            editLabel.autoAlignAxis(.vertical, toSameAxisOf: editButton)

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
}

// MARK: Private

private extension CommentEditView {
    
    func setupSubviews() {
        setupBlurView()
        setupCancelButton()
        setupDeleteButton()
        setupLikeButton()
        setupEditButton()
        setupCancelLabel()
        setupDeleteLabel()
        setupLikeLabel()
        setupEditLabel()
    }
    
    func setupBlurView() {
        
        addSubview(contentView)
    }
    
    func setupCancelButton() {
        cancelButton.setImage(UIImage(named: "ic-cancel-comment"), for: .normal)
        cancelButton.contentMode = .scaleAspectFit
        contentView.addSubview(cancelButton)
    }
    
    func setupDeleteButton() {
        deleteButton.setImage(UIImage(named: "ic-delete-comment"), for: .normal)
        deleteButton.contentMode = .scaleAspectFit
        contentView.addSubview(deleteButton)
    }
    
    func setupLikeButton() {
        likeButton.setImage(UIImage(named: "ic-like-details"), for: .normal)
        likeButton.contentMode = .scaleAspectFit
        contentView.addSubview(likeButton)
    }
    
    func setupEditButton() {
        editButton.setImage(UIImage(named: "ic-edit-comment"), for: .normal)
        editButton.contentMode = .scaleAspectFit
        contentView.addSubview(editButton)
    }
    
    func setupCancelLabel() {
        cancelLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightRegular)
        cancelLabel.textColor = ColorModeProvider.current().shotDetailsCommentEditLabelTextColor
        cancelLabel.text = NSLocalizedString("CommentEditView.Cancel", comment: "Cancel editing comment.")
        contentView.addSubview(cancelLabel)
    }
    
    func setupDeleteLabel() {
        deleteLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightRegular)
        deleteLabel.textColor = ColorModeProvider.current().shotDetailsCommentEditLabelTextColor
        deleteLabel.text = deleteLabelText
        contentView.addSubview(deleteLabel)
    }
    
    func setupLikeLabel() {
        likeLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightRegular)
        likeLabel.textColor = ColorModeProvider.current().shotDetailsCommentEditLabelTextColor
        likeLabel.text = NSLocalizedString("CommentEditView.Like",
                                           comment: "Mark selected comment as liked.")
        contentView.addSubview(likeLabel)
    }
    
    func setupEditLabel() {
        editLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightRegular)
        editLabel.textColor = ColorModeProvider.current().shotDetailsCommentEditLabelTextColor
        editLabel.text = NSLocalizedString("CommentEditView.Edit", comment: "Start editing comment.")
        contentView.addSubview(editLabel)
    }
    
    func updateLikeButtonBasedOn(_ isEditing: Bool) {
        likeButton.isHidden = isEditing
        likeLabel.isHidden = isEditing
    }
    
    func updateDeleteButtonBasedOn(_ isEditing: Bool) {
        deleteLabel.text = deleteLabelText
        let imageName = isEditing ? "ic-delete-comment" : "ic-report-comment"
        deleteButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    func updateEditButtonBasedOn(_ isEditing: Bool) {
        editButton.isHidden = !isEditing
        editLabel.isHidden = !isEditing
    }
}
