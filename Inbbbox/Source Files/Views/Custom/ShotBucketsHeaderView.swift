//
//  ShotBucketsHeaderView.swift
//  Inbbbox
//
//  Created by Peter Bruz on 24/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout
import TTTAttributedLabel

private var avatarSize: CGSize {
    return CGSize(width: 40, height: 40)
}
private var margin: CGFloat {
    return 10
}

class ShotBucketsHeaderView: UICollectionReusableView {

    var availableWidthForTitle: CGFloat {
        return avatarSize.width + 3 * margin
    }

    var maxHeight = CGFloat(0)
    var minHeight = CGFloat(0)

    var imageView: UIImageView!
    var imageDidTap: (() -> Void)?
    let avatarView = AvatarView(size: avatarSize, bordered: false)

    let closeButtonView = CloseButtonView.newAutoLayoutView()
    private let headerTitleLabel = UILabel.newAutoLayoutView()
    private let titleLabel = TTTAttributedLabel.newAutoLayoutView()

    private let gradientView = UIView.newAutoLayoutView()
    private let dimView = UIView.newAutoLayoutView()
    private let imageViewCenterWrapperView = UIView.newAutoLayoutView()

    private var imageViewCenterWrapperBottomConstraint: NSLayoutConstraint?

    private var didUpdateConstraints = false
    private var collapseProgress: CGFloat {
        return 1 - (frame.size.height - minHeight) / (maxHeight - minHeight)
    }

    private lazy var imageTapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
        return UITapGestureRecognizer(target: self, action: #selector(shotImageDidTap(_:)))
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true

        titleLabel.backgroundColor = .clearColor()
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
        addSubview(avatarView)

        imageViewCenterWrapperView.clipsToBounds = true
        addSubview(imageViewCenterWrapperView)

        gradientView.backgroundColor = .clearColor()
        imageViewCenterWrapperView.addSubview(gradientView)

        dimView.backgroundColor = UIColor(white: 0.3, alpha: 0.5)
        dimView.alpha = 0.05
        dimView.addGestureRecognizer(imageTapGestureRecognizer)
        imageViewCenterWrapperView.addSubview(dimView)

        headerTitleLabel.backgroundColor = .clearColor()
        headerTitleLabel.textColor = .whiteColor()
        headerTitleLabel.font = .helveticaFont(.NeueMedium, size: 16)
        addSubview(headerTitleLabel)

        addSubview(closeButtonView)
    }

    deinit {
        // NGRHack: animation has to be invalidated to release AnimatableShotImageView object
        if let imageView = imageView as? AnimatableShotImageView {
            let displayLink = imageView.valueForKey("displayLink") as? CADisplayLink
            displayLink?.invalidate()
        }
    }

    @available(*, unavailable, message = "Use init(frame:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let progress = collapseProgress
        let absoluteProgress = max(min(progress, 1), 0)

        imageViewCenterWrapperBottomConstraint?.constant = -minHeight + minHeight * absoluteProgress

        dimView.alpha = 0.05 + 0.95 * progress
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            let topHeaderLabelInset = CGFloat(10)
            headerTitleLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            headerTitleLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: topHeaderLabelInset)

            avatarView.autoSetDimensionsToSize(avatarSize)
            avatarView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: minHeight * 0.5 - avatarSize.height * 0.5)
            avatarView.autoPinEdgeToSuperviewEdge(.Left, withInset: margin)

            titleLabel.autoPinEdge(.Left, toEdge: .Right, ofView: avatarView, withOffset: margin)
            titleLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: margin)
            titleLabel.autoPinEdgeToSuperviewEdge(.Bottom)
            titleLabel.autoSetDimension(.Height, toSize: minHeight)

            imageViewCenterWrapperView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
            imageViewCenterWrapperBottomConstraint = imageViewCenterWrapperView.autoPinEdgeToSuperviewEdge(.Bottom,
                    withInset: minHeight)

            gradientView.autoPinEdgesToSuperviewEdges()
            dimView.autoPinEdgesToSuperviewEdges()

            closeButtonView.autoPinEdge(.Right, toEdge: .Right, ofView: imageViewCenterWrapperView, withOffset: -5)
            closeButtonView.autoPinEdge(.Top, toEdge: .Top, ofView: imageViewCenterWrapperView, withOffset: 5)
        }

        super.updateConstraints()
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)

        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.TopLeft, .TopRight],
                cornerRadii: CGSize(width: 15, height: 15))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        layer.mask = mask

        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(white: 0, alpha: 0.3).CGColor, UIColor(white: 1, alpha: 0).CGColor]
        gradient.locations = [0.0, 0.7]
        gradient.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradient, atIndex: 0)
    }

    func setAttributedTitle(title: NSAttributedString?) {
        titleLabel.setText(title)
    }

    func setHeaderTitle(title: String) {
        headerTitleLabel.text = title
    }

    func setLinkInTitle(URL: NSURL, range: NSRange, delegate: TTTAttributedLabelDelegate) {
        let linkAttributes = [
                NSForegroundColorAttributeName: UIColor.pinkColor(),
                NSFontAttributeName: UIFont.systemFontOfSize(14)
        ]
        titleLabel.linkAttributes = linkAttributes
        titleLabel.activeLinkAttributes = linkAttributes
        titleLabel.inactiveLinkAttributes = linkAttributes
        titleLabel.extendsLinkTouchArea = false
        titleLabel.addLinkToURL(URL, withRange: range)
        titleLabel.delegate = delegate
    }
}

extension ShotBucketsHeaderView {

    func setImageWithShotImage(shotImage: ShotImageType) {
        if imageView == nil {
            imageView = ShotImageView.newAutoLayoutView()
            setupImageView()
        }

        let imageCompletion: UIImage -> Void = {
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

    func setAnimatedImageWithUrl(url: NSURL) {
        if imageView == nil {
            imageView = AnimatableShotImageView.newAutoLayoutView()
            setupImageView()
        }
        let iv = imageView as? AnimatableShotImageView
        iv?.loadAnimatableShotFromUrl(url)
    }

    private func setupImageView() {
        imageViewCenterWrapperView.insertSubview(imageView!, belowSubview: gradientView)
        imageView!.autoPinEdgesToSuperviewEdges()
    }
}

private extension ShotBucketsHeaderView {

    dynamic func shotImageDidTap(_: UITapGestureRecognizer) {
        imageDidTap?()
    }
}

extension ShotBucketsHeaderView: Reusable {

    class var reuseIdentifier: String {
        return String(ShotBucketsHeaderView)
    }
}
