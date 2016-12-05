//
//  ShotAuthorCompactView.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 25.05.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import PureLayout

class ShotAuthorCompactView: UIView {

    // MARK: Public
    lazy var avatarView: AvatarView = AvatarView(size: self.avatarSize,
                                                 bordered: false)

    // MARK: Private
    private let authorLabel = UILabel.newAutoLayoutView()

    private let likesImageView: UIImageView = UIImageView(image: UIImage(named: "ic-likes-count"))
    private let likesLabel = UILabel.newAutoLayoutView()

    private let commentsImageView: UIImageView = UIImageView(image: UIImage(named: "ic-comment-count"))
    private let commentsLabel = UILabel.newAutoLayoutView()

    struct ViewData {
        let author: String
        let avatarURL: NSURL
        let liked: Bool
        let likesCount: UInt
        let commentsCount: UInt
    }

    var viewData: ViewData? {
        didSet {
            authorLabel.text = viewData?.author
            let placeholder = UIImage(named: "ic-account-nopicture")
            avatarView.imageView.loadImageFromURL((viewData?.avatarURL)!, placeholderImage: placeholder)
            if let viewData = viewData where viewData.liked {
                likesImageView.image = UIImage(named: "ic-like-details-active")
            } else {
                likesImageView.image = UIImage(named: "ic-likes-count")
            }
            likesLabel.text = "\(viewData?.likesCount ?? 0)"
            commentsLabel.text = "\(viewData?.commentsCount ?? 0)"
        }
    }

    // Private
    private var didSetupConstraints = false
    private let avatarSize = CGSize(width: 16, height: 16)
    private let likesSize = CGSize(width: 17, height: 16)
    private let commentsSize = CGSize(width: 18, height: 16)

    // MARK: Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        avatarView.backgroundColor = .clearColor()
        [authorLabel, likesLabel, commentsLabel].forEach { (label) in
            label.font = UIFont.helveticaFont(.Neue, size: 10)
            label.textColor = .followeeTextGrayColor()
        }

        addSubview(avatarView)
        addSubview(authorLabel)
        addSubview(likesImageView)
        addSubview(likesLabel)
        addSubview(commentsImageView)
        addSubview(commentsLabel)
    }

    @available(*, unavailable, message="Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIView

    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }

    override func updateConstraints() {
        if !didSetupConstraints {

            avatarView.autoSetDimensionsToSize(avatarSize)
            avatarView.autoPinEdgeToSuperviewEdge(.Leading)
            avatarView.autoAlignAxisToSuperviewAxis(.Horizontal)

            authorLabel.autoPinEdge(.Leading, toEdge: .Trailing, ofView: avatarView, withOffset: 3)
            authorLabel.autoAlignAxisToSuperviewAxis(.Horizontal)

            commentsLabel.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 3)
            commentsLabel.autoAlignAxisToSuperviewAxis(.Horizontal)

            commentsImageView.autoSetDimensionsToSize(commentsSize)
            commentsImageView.autoPinEdge(.Trailing, toEdge: .Leading, ofView: commentsLabel, withOffset: -3)
            commentsImageView.autoAlignAxisToSuperviewAxis(.Horizontal)

            likesLabel.autoPinEdge(.Trailing, toEdge: .Leading, ofView: commentsImageView, withOffset: -8)
            likesLabel.autoAlignAxisToSuperviewAxis(.Horizontal)

            likesImageView.autoSetDimensionsToSize(likesSize)
            likesImageView.autoPinEdge(.Trailing, toEdge: .Leading, ofView: likesLabel, withOffset: -3)
            likesImageView.autoAlignAxisToSuperviewAxis(.Horizontal)

            didSetupConstraints = true
        }

        super.updateConstraints()
    }

}
