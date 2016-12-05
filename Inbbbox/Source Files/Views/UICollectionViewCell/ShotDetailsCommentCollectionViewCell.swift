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
    case Editing
    case Reporting
}

class ShotDetailsCommentCollectionViewCell: UICollectionViewCell {

    weak var delegate: UICollectionViewCellWithLabelContainingClickableLinksDelegate?

    var deleteActionHandler: (() -> Void)?
    var reportActionHandler: (() -> Void)?
    var likeActionHandler: (() -> Void)?
    var unlikeActionHandler: (() -> Void)?

    let avatarView = AvatarView(size: avatarSize, bordered: false)
    let authorLabel = TTTAttributedLabel.newAutoLayoutView()
    let dateLabel = UILabel.newAutoLayoutView()
    private let likesImageView: UIImageView = UIImageView(image: UIImage(named: "ic-like-emptystate"))
    let likesCountLabel = UILabel.newAutoLayoutView()
    private let commentLabel = TTTAttributedLabel.newAutoLayoutView()
    private let editView = CommentEditView.newAutoLayoutView()
    private let separatorView = UIView.newAutoLayoutView()
    
    var likedByMe: Bool = false {
        didSet {
            editView.setLiked(withValue: likedByMe)
            likesImageView.image = UIImage(named: (likedByMe ? "ic-like-details-active" : "ic-like-emptystate"))
        }
    }

    // Regards clickable links in comment label
    private let layoutManager = NSLayoutManager()
    private let textContainer = NSTextContainer(size: CGSize.zero)
    lazy private var textStorage: NSTextStorage = { [unowned self] in
        return NSTextStorage(attributedString: self.commentLabel.attributedText ?? NSAttributedString())
    }()

    private var didUpdateConstraints = false

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
        commentLabel.lineBreakMode = .ByWordWrapping
        commentLabel.userInteractionEnabled = true
        commentLabel.linkAttributes = [NSForegroundColorAttributeName : ColorModeProvider.current().shotDetailsCommentLinkTextColor]
        commentLabel.delegate = self
        contentView.addSubview(commentLabel)

        dateLabel.numberOfLines = 0
        contentView.addSubview(dateLabel)

        likesCountLabel.font = UIFont.helveticaFont(.Neue, size: 10)
        likesCountLabel.textColor = ColorModeProvider.current().shotDetailsCommentLikesCountTextColor

        contentView.addSubview(likesImageView)
        contentView.addSubview(likesCountLabel)

        editView.cancelButton.addTarget(self,
                action: #selector(cancelButtonDidTap(_:)), forControlEvents: .TouchUpInside)
        contentView.addSubview(editView)

        editView.likeButton.addTarget(self,
                action: #selector(likeButtonDidTap(_:)), forControlEvents: .TouchUpInside)
        contentView.addSubview(editView)
        
        separatorView.backgroundColor = ColorModeProvider.current().cellSeparator
        contentView.addSubview(separatorView)

        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message = "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let preferredMaxLayoutWidth = frame.size.width - (self.dynamicType.maximumContentWidth ?? 0)

        authorLabel.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        commentLabel.preferredMaxLayoutWidth = preferredMaxLayoutWidth

        textContainer.size = commentLabel.bounds.size
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            let verticalSpacing = self.dynamicType.verticalInteritemSpacing
            let insets = self.dynamicType.contentInsets
            
            contentView.autoPinEdgesToSuperviewEdges()
            
            avatarView.autoPinEdgeToSuperviewEdge(.Left, withInset: insets.left)
            avatarView.autoPinEdgeToSuperviewEdge(.Top, withInset: insets.top)
            avatarView.autoSetDimensionsToSize(avatarView.frame.size)
            avatarView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: insets.bottom, relation: .GreaterThanOrEqual)

            authorLabel.autoPinEdge(.Top, toEdge: .Top, ofView: authorLabel.superview!, withOffset: insets.top)
            authorLabel.autoPinEdge(.Left, toEdge: .Right, ofView: avatarView,
                    withOffset: horizontalSpaceBetweenAvatarAndText)
            authorLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: insets.right)
            authorLabel.autoSetDimension(.Height, toSize: 20, relation: .GreaterThanOrEqual)

            commentLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: authorLabel, withOffset: verticalSpacing)
            commentLabel.autoPinEdge(.Bottom, toEdge: .Top, ofView: dateLabel)
            commentLabel.autoPinEdge(.Left, toEdge: .Left, ofView: authorLabel)
            commentLabel.autoPinEdge(.Right, toEdge: .Right, ofView: authorLabel, withOffset: insets.right)

            dateLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: insets.bottom)
            dateLabel.autoPinEdge(.Left, toEdge: .Left, ofView: authorLabel)
            dateLabel.autoSetDimension(.Height, toSize: 26, relation: .GreaterThanOrEqual)

            likesCountLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: dateLabel)
            likesCountLabel.autoPinEdge(.Right, toEdge: .Right, ofView: self, withOffset: -insets.right)

            likesImageView.autoSetDimensionsToSize(likesImageSize)
            likesImageView.autoAlignAxis(.Horizontal, toSameAxisOfView: dateLabel)
            likesImageView.autoPinEdge(.Trailing, toEdge: .Leading, ofView: likesCountLabel, withOffset: -3)

            editView.autoPinEdge(.Right, toEdge: .Right, ofView: self)
            editView.autoPinEdge(.Left, toEdge: .Left, ofView: self)
            editView.autoPinEdge(.Top, toEdge: .Top, ofView: self)
            editView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self)
            
            separatorView.autoPinEdge(.Left, toEdge: .Left, ofView: dateLabel)
            separatorView.autoPinEdgeToSuperviewEdge(.Right)
            separatorView.autoPinEdgeToSuperviewEdge(.Bottom)
            separatorView.autoSetDimension(.Height, toSize: 1)
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
                                           forControlEvents: .TouchUpInside)
        editView.deleteButton.removeTarget(self,
                                           action: #selector(reportButtonDidTap(_:)),
                                           forControlEvents: .TouchUpInside)
        showEditView(false)
        likedByMe = false
    }

    func showEditView(show: Bool, forActionType action: EditActionType = .Editing) {

        editView.hidden = !show

        guard show else { return }

        switch action {
        case .Editing:
            editView.configureForEditing()
            editView.deleteButton.addTarget(self,
                                            action: #selector(deleteButtonDidTap(_:)), forControlEvents: .TouchUpInside)
        case .Reporting:
            editView.configureForReporting()
            editView.deleteButton.addTarget(self,
                                            action: #selector(reportButtonDidTap(_:)), forControlEvents: .TouchUpInside)
        }
    }

    func setCommentLabelAttributedText(attributedText: NSAttributedString) {

        commentLabel.setText(attributedText)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = commentLabel.lineBreakMode
        textContainer.maximumNumberOfLines = commentLabel.numberOfLines
    }

    func setLinkInAuthorLabel(URL: NSURL, delegate: TTTAttributedLabelDelegate) {
        let linkAttributes = [
                NSForegroundColorAttributeName: ColorModeProvider.current().shotDetailsCommentAuthorTextColor,
                NSFontAttributeName: UIFont.helveticaFont(.NeueMedium, size: 16)
        ]
        let authorText = authorLabel.text ?? ""
        let range = NSRange(location: 0, length: authorText.characters.count)
        authorLabel.linkAttributes = linkAttributes
        authorLabel.activeLinkAttributes = linkAttributes
        authorLabel.inactiveLinkAttributes = linkAttributes
        authorLabel.extendsLinkTouchArea = false
        authorLabel.addLinkToURL(URL, withRange: range)
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
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
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

extension ShotDetailsCommentCollectionViewCell: Reusable {

    class var reuseIdentifier: String {
        return String(ShotDetailsCommentCollectionViewCell)
    }
}
