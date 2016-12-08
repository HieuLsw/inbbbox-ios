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

class ShotBucketsHeaderView: UICollectionReusableView, Reusable {

    var availableWidthForTitle: CGFloat {
        return avatarSize.width + 3 * margin
    }

    var maxHeight = CGFloat(0)
    var minHeight = CGFloat(0)

    var imageView: UIImageView!
    var imageDidTap: (() -> Void)?
    let avatarView = AvatarView(size: avatarSize, bordered: false)

    let closeButtonView = CloseButtonView.newAutoLayout()
    fileprivate let headerTitleLabel = UILabel.newAutoLayout()
    fileprivate let titleLabel = TTTAttributedLabel.newAutoLayout()

    fileprivate let gradientView = UIView.newAutoLayout()
    fileprivate let dimView = UIView.newAutoLayout()
    fileprivate let imageViewCenterWrapperView = UIView.newAutoLayout()

    fileprivate var imageViewCenterWrapperBottomConstraint: NSLayoutConstraint?

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
        addSubview(titleLabel)
        addSubview(avatarView)

        imageViewCenterWrapperView.clipsToBounds = true
        addSubview(imageViewCenterWrapperView)

        gradientView.backgroundColor = .clear
        imageViewCenterWrapperView.addSubview(gradientView)

        dimView.backgroundColor = UIColor(white: 0.3, alpha: 0.5)
        dimView.alpha = 0.05
        dimView.addGestureRecognizer(imageTapGestureRecognizer)
        imageViewCenterWrapperView.addSubview(dimView)

        headerTitleLabel.backgroundColor = .clear
        headerTitleLabel.textColor = .white
        headerTitleLabel.font = .helveticaFont(.neueMedium, size: 16)
        addSubview(headerTitleLabel)

        addSubview(closeButtonView)
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
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            let topHeaderLabelInset = CGFloat(10)
            headerTitleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
            headerTitleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: topHeaderLabelInset)

            avatarView.autoSetDimensions(to: avatarSize)
            avatarView.autoPinEdge(toSuperviewEdge: .bottom, withInset: minHeight * 0.5 - avatarSize.height * 0.5)
            avatarView.autoPinEdge(toSuperviewEdge: .left, withInset: margin)

            titleLabel.autoPinEdge(.left, to: .right, of: avatarView, withOffset: margin)
            titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: margin)
            titleLabel.autoPinEdge(toSuperviewEdge: .bottom)
            titleLabel.autoSetDimension(.height, toSize: minHeight)

            imageViewCenterWrapperView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .bottom)
            imageViewCenterWrapperBottomConstraint = imageViewCenterWrapperView.autoPinEdge(toSuperviewEdge: .bottom,
                    withInset: minHeight)

            gradientView.autoPinEdgesToSuperviewEdges()
            dimView.autoPinEdgesToSuperviewEdges()

            closeButtonView.autoPinEdge(.right, to: .right, of: imageViewCenterWrapperView, withOffset: -5)
            closeButtonView.autoPinEdge(.top, to: .top, of: imageViewCenterWrapperView, withOffset: 5)
        }

        super.updateConstraints()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight],
                cornerRadii: CGSize(width: 15, height: 15))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask

        let gradient = CAGradientLayer()
        gradient.colors = [UIColor(white: 0, alpha: 0.3).cgColor, UIColor(white: 1, alpha: 0).cgColor]
        gradient.locations = [0.0, 0.7]
        gradient.frame = gradientView.bounds
        gradientView.layer.insertSublayer(gradient, at: 0)
    }

    func setAttributedTitle(_ title: NSAttributedString?) {
        titleLabel.setText(title)
    }

    func setHeaderTitle(_ title: String) {
        headerTitleLabel.text = title
    }

    func setLinkInTitle(_ URL: URL, range: NSRange, delegate: TTTAttributedLabelDelegate) {
        let linkAttributes = [
                NSForegroundColorAttributeName: UIColor.pinkColor(),
                NSFontAttributeName: UIFont.sanFransiscoFont(ofSize: 14)
        ]
        titleLabel.linkAttributes = linkAttributes
        titleLabel.activeLinkAttributes = linkAttributes
        titleLabel.inactiveLinkAttributes = linkAttributes
        titleLabel.extendsLinkTouchArea = false
        titleLabel.addLink(to: URL, with: range)
        titleLabel.delegate = delegate
    }
}

extension ShotBucketsHeaderView {

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
        imageViewCenterWrapperView.insertSubview(imageView!, belowSubview: gradientView)
        imageView!.autoPinEdgesToSuperviewEdges()
    }
}

private extension ShotBucketsHeaderView {

    dynamic func shotImageDidTap(_: UITapGestureRecognizer) {
        imageDidTap?()
    }
}
