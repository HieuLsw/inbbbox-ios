//
//  ShotDetailsCommentCollectionViewCell.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 22/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import TTTAttributedLabel

private var avatarSize: CGSize {
    return CGSize(width: 32, height: 32)
}

private var likesImageSize: CGSize {
    return CGSize(width: 12, height: 12)
}

private var horizontalSpaceBetweenAvatarAndText: CGFloat {
    return 15
}

enum EditActionType {
    case editing
    case reporting
}

class ShotDetailsCommentCollectionViewCell: UICollectionViewCell, Reusable {

    weak var delegate: UICollectionViewCellWithLabelContainingClickableLinksDelegate?

    var deleteActionHandler: (() -> Void)?
    var reportActionHandler: (() -> Void)?
    var likeActionHandler: (() -> Void)?
    var unlikeActionHandler: (() -> Void)?

    let avatarView = AvatarView(size: avatarSize, bordered: false)
    let authorLabel = TTTAttributedLabel.newAutoLayout()
    let dateLabel = UILabel.newAutoLayout()
    fileprivate let likesImageView: UIImageView = UIImageView(image: UIImage(named: "ic-like-emptystate"))
    let likesCountLabel = UILabel.newAutoLayout()
    fileprivate let commentLabel = TTTAttributedLabel.newAutoLayout()
    fileprivate let editView = CommentEditView.newAutoLayout()
    fileprivate let separatorView = UIView.newAutoLayout()
    
    var likedByMe: Bool = false {
        didSet {
            editView.setLiked(withValue: likedByMe)
            likesImageView.image = UIImage(named: (likedByMe ? "ic-like-details-active" : "ic-like-emptystate"))
        }
    }

    // Regards clickable links in comment label
    fileprivate let layoutManager = NSLayoutManager()
    fileprivate let textContainer = NSTextContainer(size: CGSize.zero)
    lazy fileprivate var textStorage: NSTextStorage = { [unowned self] in
        return NSTextStorage(attributedString: self.commentLabel.attributedText ?? NSAttributedString())
    }()

    fileprivate var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        showEditView(false)
        configureForAutoLayout()

        contentView.configureForAutoLayout()

        avatarView.configureForAutoLayout()
        avatarView.imageView.image = UIImage(named: "ic-comments-nopicture")
        contentView.addSubview(avatarView)

        authorLabel.numberOfLines = 0
        contentView.addSubview(authorLabel)

        commentLabel.numberOfLines = 0
        commentLabel.lineBreakMode = .byWordWrapping
        commentLabel.isUserInteractionEnabled = true
        commentLabel.linkAttributes = [NSForegroundColorAttributeName : ColorModeProvider.current().shotDetailsCommentLinkTextColor]
        commentLabel.delegate = self
        contentView.addSubview(commentLabel)

        dateLabel.numberOfLines = 0
        contentView.addSubview(dateLabel)

        likesCountLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightRegular)
        likesCountLabel.textColor = ColorModeProvider.current().shotDetailsCommentLikesCountTextColor

        contentView.addSubview(likesImageView)
        contentView.addSubview(likesCountLabel)

        editView.cancelButton.addTarget(self,
                action: #selector(cancelButtonDidTap(_:)), for: .touchUpInside)
        contentView.addSubview(editView)

        editView.likeButton.addTarget(self,
                action: #selector(likeButtonDidTap(_:)), for: .touchUpInside)
        contentView.addSubview(editView)
        
        separatorView.backgroundColor = ColorModeProvider.current().cellSeparator
        contentView.addSubview(separatorView)

        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let preferredMaxLayoutWidth = frame.size.width - (type(of: self).maximumContentWidth ?? 0)

        authorLabel.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        commentLabel.preferredMaxLayoutWidth = preferredMaxLayoutWidth

        textContainer.size = commentLabel.bounds.size
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            let verticalSpacing = type(of: self).verticalInteritemSpacing
            let insets = type(of: self).contentInsets
            
            contentView.autoPinEdgesToSuperviewEdges()
            
            avatarView.autoPinEdge(toSuperviewEdge: .left, withInset: insets.left)
            avatarView.autoPinEdge(toSuperviewEdge: .top, withInset: insets.top)
            avatarView.autoSetDimensions(to: avatarView.frame.size)
            avatarView.autoPinEdge(toSuperviewEdge: .bottom, withInset: insets.bottom, relation: .greaterThanOrEqual)

            authorLabel.autoPinEdge(.top, to: .top, of: avatarView)
            authorLabel.autoPinEdge(.left, to: .right, of: avatarView, withOffset: horizontalSpaceBetweenAvatarAndText)
            authorLabel.autoPinEdge(toSuperviewEdge: .right, withInset: insets.right)

            commentLabel.autoPinEdge(.top, to: .bottom, of: authorLabel, withOffset: verticalSpacing)
            commentLabel.autoPinEdge(.left, to: .left, of: authorLabel)
            commentLabel.autoPinEdge(.right, to: .right, of: authorLabel, withOffset: insets.right)

            dateLabel.autoPinEdge(.top, to: .bottom, of: commentLabel, withOffset: verticalSpacing, relation: .greaterThanOrEqual)
            dateLabel.autoPinEdge(.left, to: .left, of: authorLabel)
            dateLabel.autoPinEdge(.bottom, to: .bottom, of: separatorView, withOffset: -verticalSpacing)

            likesCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: dateLabel)
            likesCountLabel.autoPinEdge(.right, to: .right, of: self, withOffset: -insets.right)

            likesImageView.autoSetDimensions(to: likesImageSize)
            likesImageView.autoAlignAxis(.horizontal, toSameAxisOf: dateLabel)
            likesImageView.autoPinEdge(.trailing, to: .leading, of: likesCountLabel, withOffset: -3)

            editView.autoPinEdge(.right, to: .right, of: self)
            editView.autoPinEdge(.left, to: .left, of: self)
            editView.autoPinEdge(.top, to: .top, of: self)
            editView.autoPinEdge(.bottom, to: .bottom, of: self)
            
            separatorView.autoPinEdge(.left, to: .left, of: dateLabel)
            separatorView.autoPinEdge(toSuperviewEdge: .right)
            separatorView.autoPinEdge(toSuperviewEdge: .bottom)
            separatorView.autoSetDimension(.height, toSize: 1)
        }

        super.updateConstraints()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        authorLabel.attributedText = nil
        commentLabel.attributedText = nil
        dateLabel.attributedText = nil
        avatarView.imageView.image = nil
        editView.deleteButton.removeTarget(self,
                                           action: #selector(deleteButtonDidTap(_:)),
                                           for: .touchUpInside)
        editView.deleteButton.removeTarget(self,
                                           action: #selector(reportButtonDidTap(_:)),
                                           for: .touchUpInside)
        showEditView(false)
        likedByMe = false
    }

    func showEditView(_ show: Bool, forActionType action: EditActionType = .editing) {

        editView.isHidden = !show

        guard show else { return }

        switch action {
        case .editing:
            editView.configureForEditing()
            editView.deleteButton.addTarget(self,
                                            action: #selector(deleteButtonDidTap(_:)), for: .touchUpInside)
        case .reporting:
            editView.configureForReporting()
            editView.deleteButton.addTarget(self,
                                            action: #selector(reportButtonDidTap(_:)), for: .touchUpInside)
        }
    }

    func setCommentLabelAttributedText(_ attributedText: NSAttributedString) {

        commentLabel.setText(attributedText)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = commentLabel.lineBreakMode
        textContainer.maximumNumberOfLines = commentLabel.numberOfLines
    }

    func setLinkInAuthorLabel(_ URL: URL, delegate: TTTAttributedLabelDelegate) {
        let linkAttributes = [
                NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsCommentAuthorTextColor,
                NSFontAttributeName: UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        ]
        let authorText = authorLabel.text ?? ""
        let range = NSRange(location: 0, length: authorText.characters.count)
        authorLabel.linkAttributes = linkAttributes
        authorLabel.activeLinkAttributes = linkAttributes
        authorLabel.inactiveLinkAttributes = linkAttributes
        authorLabel.extendsLinkTouchArea = false
        authorLabel.addLink(to: URL, with: range)
        authorLabel.delegate = delegate
    }
}

extension ShotDetailsCommentCollectionViewCell {

    func reportButtonDidTap(_: UIButton) {
        reportActionHandler?()
    }

    func deleteButtonDidTap(_: UIButton) {
        deleteActionHandler?()
    }

    func cancelButtonDidTap(_: UIButton) {
        showEditView(false)
    }

    func likeButtonDidTap(_: UIButton) {
        likedByMe ? unlikeActionHandler?() : likeActionHandler?()
    }

}

extension ShotDetailsCommentCollectionViewCell: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        delegate?.urlInLabelTapped(url)
    }
}

extension ShotDetailsCommentCollectionViewCell: AutoSizable {

    static var maximumContentWidth: CGFloat? {
        return contentInsets.left + contentInsets.right + avatarSize.width + horizontalSpaceBetweenAvatarAndText
    }

    static var minimumRequiredHeight: CGFloat {
        return contentInsets.top + contentInsets.bottom + avatarSize.height
    }

    static var contentInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 10)
    }

    static var verticalInteritemSpacing: CGFloat {
        return 5
    }
}
