//
//  ShotAuthorCompactView.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 25.05.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import PureLayout

class ShotAuthorCompactView: UIView {

    // MARK: Internal
    lazy var avatarView: AvatarView = AvatarView(size: self.avatarSize,
                                                 bordered: false)

    // MARK: Private
    fileprivate let authorLabel = UILabel.newAutoLayout()

    fileprivate let likesImageView: UIImageView = UIImageView(image: UIImage(named: "ic-likes-count"))
    fileprivate let likesLabel = UILabel.newAutoLayout()

    fileprivate let commentsImageView: UIImageView = UIImageView(image: UIImage(named: "ic-comment-count"))
    fileprivate let commentsLabel = UILabel.newAutoLayout()

    struct ViewData {
        let author: String
        let avatarURL: URL
        let liked: Bool
        let likesCount: UInt
        let commentsCount: UInt
    }

    var viewData: ViewData? {
        didSet {
            authorLabel.text = viewData?.author
            let placeholder = UIImage(named: "ic-account-nopicture")
            avatarView.imageView.loadImageFromURL((viewData?.avatarURL)!, placeholderImage: placeholder)
            if let viewData = viewData, viewData.liked {
                setLikesIconActive()
            } else {
                setLikesIconInactive()
            }
            likesLabel.text = "\(viewData?.likesCount ?? 0)"
            commentsLabel.text = "\(viewData?.commentsCount ?? 0)"
        }
    }

    // Private
    fileprivate var didSetupConstraints = false
    fileprivate let avatarSize = CGSize(width: 16, height: 16)
    fileprivate let likesSize = CGSize(width: 17, height: 16)
    fileprivate let commentsSize = CGSize(width: 18, height: 16)

    // MARK: Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        avatarView.backgroundColor = .clear
        [authorLabel, likesLabel, commentsLabel].forEach { (label) in
            label.font = UIFont.sanFransiscoFont(withType: .regular, size: 10)
            label.textColor = .followeeTextGrayColor()
        }

        addSubview(avatarView)
        addSubview(authorLabel)
        addSubview(likesImageView)
        addSubview(likesLabel)
        addSubview(commentsImageView)
        addSubview(commentsLabel)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    func setLikesIconActive() {
        likesImageView.image = UIImage(named: "ic-like-details-active")
    }

    func setLikesIconInactive() {
        likesImageView.image = UIImage(named: "ic-likes-count")
    }

    func incrementLikesNumber() {
        if let currentCount = viewData?.likesCount {
            likesLabel.text = "\(currentCount + 1)"
        }
    }

    func decrementLikesNumber() {
        if let currentCount = viewData?.likesCount {
            likesLabel.text = "\(currentCount + 1)"
        }
    }

    // MARK: Subclassing

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override func updateConstraints() {
        if !didSetupConstraints {

            avatarView.autoSetDimensions(to: avatarSize)
            avatarView.autoPinEdge(toSuperviewEdge: .leading)
            avatarView.autoAlignAxis(toSuperviewAxis: .horizontal)

            authorLabel.autoPinEdge(.leading, to: .trailing, of: avatarView, withOffset: 3)
            authorLabel.autoAlignAxis(toSuperviewAxis: .horizontal)

            commentsLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 3)
            commentsLabel.autoAlignAxis(toSuperviewAxis: .horizontal)

            commentsImageView.autoSetDimensions(to: commentsSize)
            commentsImageView.autoPinEdge(.trailing, to: .leading, of: commentsLabel, withOffset: -3)
            commentsImageView.autoAlignAxis(toSuperviewAxis: .horizontal)

            likesLabel.autoPinEdge(.trailing, to: .leading, of: commentsImageView, withOffset: -8)
            likesLabel.autoAlignAxis(toSuperviewAxis: .horizontal)

            likesImageView.autoSetDimensions(to: likesSize)
            likesImageView.autoPinEdge(.trailing, to: .leading, of: likesLabel, withOffset: -3)
            likesImageView.autoAlignAxis(toSuperviewAxis: .horizontal)

            didSetupConstraints = true
        }

        super.updateConstraints()
    }

}
