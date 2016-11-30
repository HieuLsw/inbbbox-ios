//
//  ShotDetailsHeaderView.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 18/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout
import Haneke
import TTTAttributedLabel

private var avatarSize: CGSize {
    return CGSize(width: 48, height: 48)
}
private var margin: CGFloat {
    return 10
}

class ShotDetailsHeaderView: UICollectionReusableView, Reusable {
    
    var showAttachments: Bool = false {
        didSet {
            attachmentContainer.isHidden = !showAttachments
        }
    }
    var attachments:[Attachment] = [Attachment]() {
        didSet {
            attachmentsCollectionView.reloadData()
        }
    }
    var attachmentDidTap: ((UICollectionViewCell, Attachment) -> Void)?
    var selectedAttachment: Attachment?

    var availableWidthForTitle: CGFloat {
        return avatarSize.width + 3 * margin
    }

    var maxHeight = CGFloat(0)
    var minHeight = CGFloat(0)

    var imageView: UIImageView!
    var imageDidTap: (() -> Void)?
    let avatarView = AvatarView(size: avatarSize, bordered: false)

    let closeButtonView = CloseButtonView.newAutoLayout()
    fileprivate let titleLabel = TTTAttributedLabel.newAutoLayout()
    fileprivate let overlapingTitleLabel = UILabel.newAutoLayout()
    fileprivate let dimView = UIView.newAutoLayout()
    fileprivate let imageViewCenterWrapperView = UIView.newAutoLayout()
    fileprivate let shadowImageView = UIImageView.newAutoLayout()
    fileprivate let attachmentContainer = UIView.newAutoLayout()
    fileprivate lazy var attachmentsCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())

    fileprivate var imageViewCenterWrapperBottomConstraint: NSLayoutConstraint?
    fileprivate var attachmentContainerHeightConstraint: NSLayoutConstraint?

    fileprivate var didUpdateConstraints = false
    fileprivate var collapseProgress: CGFloat {
        return 1 - (frame.size.height - minHeight) / (maxHeight - minHeight)
    }

    fileprivate lazy var imageTapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
        return UITapGestureRecognizer(target: self, action: #selector(shotImageDidTap(_:)))
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true

        titleLabel.backgroundColor = .clear
        titleLabel.numberOfLines = 0
        titleLabel.textColor = ColorModeProvider.current().shotDetailsHeaderViewTitleLabelTextColor
        addSubview(titleLabel)

        imageViewCenterWrapperView.clipsToBounds = true
        addSubview(imageViewCenterWrapperView)

        shadowImageView.image = UIImage(named: "DetailsShadow")
        shadowImageView.contentMode = .scaleToFill
        addSubview(shadowImageView)

        dimView.backgroundColor = UIColor(white: 0.3, alpha: 0.5)
        dimView.alpha = 0.05
        dimView.addGestureRecognizer(imageTapGestureRecognizer)
        imageViewCenterWrapperView.addSubview(dimView)

        overlapingTitleLabel.backgroundColor = .clear
        overlapingTitleLabel.numberOfLines = 0
        overlapingTitleLabel.alpha = 0
        addSubview(overlapingTitleLabel)

        avatarView.imageView.image = UIImage(named: "ic-author-mugshot-nopicture")
        addSubview(avatarView)

        addSubview(closeButtonView)

        setNeedsUpdateConstraints()
        
        attachmentContainer.backgroundColor = UIColor.RGBA(43, 49, 51, 1)
        insertSubview(attachmentContainer, aboveSubview: titleLabel)
        
        attachmentsCollectionView.register(AttachmentCollectionViewCell.self, forCellWithReuseIdentifier: AttachmentCollectionViewCell.identifier)
        attachmentsCollectionView.backgroundColor = .clear
        attachmentsCollectionView.dataSource = self
        attachmentsCollectionView.delegate = self
        attachmentsCollectionView.showsHorizontalScrollIndicator = false
        if let layout = attachmentsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 80, height: 60)
            layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
            layout.scrollDirection = .horizontal
        }
        
        attachmentContainer.addSubview(attachmentsCollectionView)
    }

    deinit {
        // Animation has to be invalidated to release AnimatableShotImageView object
        if let imageView = imageView as? AnimatableShotImageView {
            let displayLink = imageView.value(forKey: "displayLink") as? CADisplayLink
            displayLink?.invalidate()
        }
    }

    @available(*, unavailable, message: "Use init(frame:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let progress = collapseProgress
        let absoluteProgress = max(min(progress, 1), 0)

        imageViewCenterWrapperBottomConstraint?.constant = -minHeight + minHeight * absoluteProgress

        dimView.alpha = 0.05 + 0.95 * progress
        overlapingTitleLabel.alpha = progress
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            avatarView.autoSetDimensions(to: avatarSize)
            avatarView.autoPinEdge(.top, to: .top, of: titleLabel, withOffset: 20)
            avatarView.autoPinEdge(toSuperviewEdge: .left, withInset: 20)

            titleLabel.autoPinEdge(.left, to: .right, of: avatarView, withOffset: 15)
            titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: margin)
            titleLabel.autoPinEdge(toSuperviewEdge: .bottom)
            titleLabel.autoSetDimension(.height, toSize: minHeight)

            overlapingTitleLabel.autoMatch(.height, to: .height, of: titleLabel)
            overlapingTitleLabel.autoMatch(.width, to: .width, of: titleLabel)
            overlapingTitleLabel.autoPinEdge(.left, to: .left, of: titleLabel)
            overlapingTitleLabel.autoPinEdge(.top, to: .top, of: titleLabel)

            imageViewCenterWrapperView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .bottom)
            imageViewCenterWrapperView.autoMatch(.height, to: .width, of: imageViewCenterWrapperView, withMultiplier: 0.75)

            attachmentContainer.autoPinEdge(.top, to: .bottom, of: imageViewCenterWrapperView)
            attachmentContainer.autoPinEdge(toSuperviewEdge: .left)
            attachmentContainer.autoPinEdge(toSuperviewEdge: .right)
            attachmentContainer.autoSetDimension(.height, toSize: 70)
            
            attachmentsCollectionView.autoSetDimension(.height, toSize: 60)
            attachmentsCollectionView.autoAlignAxis(toSuperviewAxis: .horizontal)
            attachmentsCollectionView.autoPinEdge(toSuperviewEdge: .left, withInset: 5)
            attachmentsCollectionView.autoPinEdge(toSuperviewEdge: .right, withInset: 5)

            shadowImageView.autoPinEdge(.top, to: .bottom, of: imageViewCenterWrapperView)
            shadowImageView.autoPinEdge(toSuperviewEdge: .left)
            shadowImageView.autoPinEdge(toSuperviewEdge: .right)
            shadowImageView.autoSetDimension(.height, toSize: shadowImageView.image?.size.height ?? 0)

            dimView.autoPinEdgesToSuperviewEdges()

            closeButtonView.autoPinEdge(.right, to: .right, of: imageViewCenterWrapperView, withOffset: -5)
            closeButtonView.autoPinEdge(.top, to: .top, of: imageViewCenterWrapperView, withOffset: 5)
        }

        super.updateConstraints()
    }

    func setAttributedTitle(_ title: NSAttributedString?) {
        titleLabel.setText(title)
        overlapingTitleLabel.attributedText = {
            guard let title = title else {
                return nil
            }

            let mutableTitle = NSMutableAttributedString(attributedString: title)
            let range = NSRange(location: 0, length: title.length)
            mutableTitle.addAttribute(NSForegroundColorAttributeName,
                                      value: ColorModeProvider.current().shotDetailsHeaderViewOverlappingTitleLabelTextColor,
                                      range: range)

            return mutableTitle.copy() as? NSAttributedString
        }()
    }

    func setLinkInTitle(_ URL: URL, range: NSRange, delegate: TTTAttributedLabelDelegate) {
        let linkAttributes = [
                NSForegroundColorAttributeName: UIColor.pinkColor(),
                NSFontAttributeName: UIFont.systemFont(ofSize: 14)
        ]
        titleLabel.linkAttributes = linkAttributes
        titleLabel.activeLinkAttributes = linkAttributes
        titleLabel.inactiveLinkAttributes = linkAttributes
        titleLabel.extendsLinkTouchArea = false
        titleLabel.addLink(to: URL, with: range)
        titleLabel.delegate = delegate
    }
}

extension ShotDetailsHeaderView {

    func setImageWithShotImage(_ shotImage: ShotImageType) {
        if imageView == nil {
            imageView = ShotImageView.newAutoLayout()
            setupImageView()
        }

        let imageCompletion: (UIImage) -> Void = {
            [weak self] image in
            if let imageView = self?.imageView {
                imageView.image = image
            }
        }

        LazyImageProvider.lazyLoadImageFromURLs(
            (teaserURL: shotImage.teaserURL, normalURL: shotImage.normalURL, hidpiURL: shotImage.hidpiURL),
            teaserImageCompletion: imageCompletion,
            normalImageCompletion: imageCompletion,
            hidpiImageCompletion: imageCompletion
        )
    }

    func setAnimatedImageWithUrl(_ url: URL) {
        if imageView == nil {
            imageView = AnimatableShotImageView.newAutoLayout()
            setupImageView()
        }
        let iv = imageView as? AnimatableShotImageView
        iv?.loadAnimatableShotFromUrl(url)
    }

    fileprivate func setupImageView() {
        imageViewCenterWrapperView.insertSubview(imageView, belowSubview: dimView)
        imageView.autoPinEdgesToSuperviewEdges()
    }
}

extension ShotDetailsHeaderView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AttachmentCollectionViewCell.identifier, for: indexPath)
        if let cell = cell as? AttachmentCollectionViewCell, let thumbnail = attachments[indexPath.row].thumbnailURL {
            cell.imageView.loadImageFromURL(thumbnail)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        attachmentDidTap?(collectionView.cellForItem(at: indexPath)!, attachments[indexPath.row])
    }
}

private extension ShotDetailsHeaderView {
    
    dynamic func shotImageDidTap(_: UITapGestureRecognizer) {
        imageDidTap?()
    }
}
