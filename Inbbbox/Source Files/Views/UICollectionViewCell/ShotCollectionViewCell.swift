//
// Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

protocol ShotCollectionViewCellDelegate: class {
    func shotCollectionViewCellDidStartSwiping(_ shotCollectionViewCell: ShotCollectionViewCell)

    func shotCollectionViewCellDidEndSwiping(_ shotCollectionViewCell: ShotCollectionViewCell)
}

class ShotCollectionViewCell: UICollectionViewCell, Reusable {

    enum Action {
        case doNothing
        case like
        case bucket
        case comment
        case follow
    }

    let shotImageView = ShotImageView.newAutoLayout()
    let likeImageView = DoubleImageView(firstImage: UIImage(named: "ic-like-swipe"),
                                        secondImage: UIImage(named: "ic-like-swipe-filled"))
    let plusImageView = UIImageView(image: UIImage(named: "ic-plus"))
    let bucketImageView = DoubleImageView(firstImage: UIImage(named: "ic-bucket-swipe"),
                                          secondImage: UIImage(named: "ic-bucket-swipe-filled"))
    let commentImageView = DoubleImageView(firstImage: UIImage(named: "ic-comment"),
                                           secondImage: UIImage(named: "ic-comment-filled"))
    let followImageView = DoubleImageView(firstImage: UIImage(named: "ic-follow-swipe"),
                                          secondImage: UIImage(named: "ic-follow-swipe-active"))
    let gifLabel = GifIndicatorView()
    let messageLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.helveticaFont(.neueBold, size: 15)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()
    

    let shotContainer = UIView.newAutoLayout()
    let authorView = ShotAuthorCompactView.newAutoLayout()
    var configureForDisplayingAuthorView = false

    fileprivate(set) var likeImageViewLeftConstraint: NSLayoutConstraint?
    fileprivate(set) var likeImageViewWidthConstraint: NSLayoutConstraint?
    fileprivate(set) var plusImageViewWidthConstraint: NSLayoutConstraint?
    fileprivate(set) var bucketImageViewWidthConstraint: NSLayoutConstraint?
    fileprivate(set) var commentImageViewRightConstraint: NSLayoutConstraint?
    fileprivate(set) var commentImageViewWidthConstraint: NSLayoutConstraint?
    fileprivate(set) var followImageViewWidthConstraint: NSLayoutConstraint?
    fileprivate var authorInfoHeightConstraint: NSLayoutConstraint?

    var viewClass = UIView.self
    var swipeCompletion: ((Action) -> Void)?
    weak var delegate: ShotCollectionViewCellDelegate?
    var isRegisteredTo3DTouch = false

    fileprivate let panGestureRecognizer = UIPanGestureRecognizer()

    fileprivate let likeActionRange = ActionRange(min: 40, max: 120)
    fileprivate let bucketActionRange = ActionRange(min: 120, max: 170)
    fileprivate let commentActionRange = ActionRange(min: -80, max: 0)
    fileprivate let followActionRange = ActionRange(min: -170, max: -80)
    fileprivate let authorInfoHeight: CGFloat = 25

    fileprivate var didSetConstraints = false
    var previousXTranslation: CGFloat = 0

    var liked = false {
        didSet {
            if liked {
                self.likeImageView.displaySecondImageView()
            } else {
                self.likeImageView.displayFirstImageView()
            }
        }
    }
    var enabledActions:[Action] = [.doNothing, .like, .bucket, .comment, .follow]

    // MARK: - Life cycle

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        let cornerRadius: CGFloat = 5

        contentView.layer.cornerRadius = cornerRadius
        contentView.clipsToBounds = true

        shotContainer.backgroundColor = .pinkColor()
        shotContainer.layer.cornerRadius = cornerRadius
        shotContainer.clipsToBounds = true

        likeImageView.configureForAutoLayout()
        shotContainer.addSubview(likeImageView)

        plusImageView.configureForAutoLayout()
        shotContainer.addSubview(plusImageView)

        bucketImageView.configureForAutoLayout()
        shotContainer.addSubview(bucketImageView)

        commentImageView.configureForAutoLayout()
        shotContainer.addSubview(commentImageView)
        
        followImageView.configureForAutoLayout()
        followImageView.alpha = 0
        shotContainer.addSubview(followImageView)
        
        messageLabel.configureForAutoLayout()
        shotContainer.addSubview(messageLabel)

        shotContainer.addSubview(shotImageView)

        gifLabel.configureForAutoLayout()
        shotContainer.addSubview(gifLabel)

        contentView.addSubview(shotContainer)

        authorView.alpha = 0
        contentView.addSubview(authorView)

        panGestureRecognizer.addTarget(self, action: #selector(didSwipeCell(_:)))
        panGestureRecognizer.delegate = self
        contentView.addGestureRecognizer(panGestureRecognizer)
    }

    // MARK: - UIView

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override func updateConstraints() {

        if !didSetConstraints {
            shotContainer.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .bottom)
            shotContainer.autoPinEdge(.bottom, to: .top, of: authorView)
            let height = configureForDisplayingAuthorView ? authorInfoHeight : 0

            authorInfoHeightConstraint = authorView.autoSetDimension(.height, toSize: height)
            authorView.autoPinEdge(toSuperviewEdge: .leading, withInset: 2)
            authorView.autoPinEdge(toSuperviewEdge: .trailing)
            authorView.autoPinEdge(toSuperviewEdge: .bottom)

            shotImageView.autoPinEdgesToSuperviewEdges()

            likeImageViewWidthConstraint = likeImageView.autoSetDimension(.width, toSize: 0)
            likeImageView.autoConstrainAttribute(.height,
                to: .width, of: likeImageView, withMultiplier: likeImageView.intrinsicContentSize.height / likeImageView.intrinsicContentSize.width)
            likeImageViewLeftConstraint = likeImageView.autoPinEdge(toSuperviewEdge: .left)
            likeImageView.autoAlignAxis(toSuperviewAxis: .horizontal)

            plusImageViewWidthConstraint = plusImageView.autoSetDimension(.width, toSize: 0)
            plusImageView.autoConstrainAttribute(.height, to: .width, of: plusImageView,
                    withMultiplier: plusImageView.intrinsicContentSize.height /
                            plusImageView.intrinsicContentSize.width)
            plusImageView.autoPinEdge(.left, to: .right, of: likeImageView, withOffset: 15)
            plusImageView.autoAlignAxis(toSuperviewAxis: .horizontal)

            bucketImageViewWidthConstraint = bucketImageView.autoSetDimension(.width, toSize: 0)
            bucketImageView.autoConstrainAttribute(.height, to: .width, of: bucketImageView,
                    withMultiplier: bucketImageView.intrinsicContentSize.height /
                            bucketImageView.intrinsicContentSize.width)
            bucketImageView.autoPinEdge(.left, to: .right, of: plusImageView, withOffset: 15)
            bucketImageView.autoAlignAxis(toSuperviewAxis: .horizontal)

            commentImageViewWidthConstraint = commentImageView.autoSetDimension(.width, toSize: 0)
            commentImageView.autoConstrainAttribute(.height, to: .width, of: commentImageView,
                    withMultiplier: commentImageView.intrinsicContentSize.height /
                            commentImageView.intrinsicContentSize.width)
            commentImageViewRightConstraint = commentImageView.autoPinEdge(toSuperviewEdge: .right)
            commentImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            
            followImageViewWidthConstraint = followImageView.autoSetDimension(.width, toSize: 0)
            followImageView.autoConstrainAttribute(.height, to: .width, of: followImageView,
                    withMultiplier: followImageView.intrinsicContentSize.height /
                            followImageView.intrinsicContentSize.width)
            followImageView.autoAlignAxis(.vertical, toSameAxisOf: commentImageView)
            followImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            
            gifLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
            gifLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 10)

            messageLabel.autoAlignAxis(toSuperviewAxis: .vertical)
            let messageHorizontalOffset = followImageView.intrinsicContentSize.height
            messageLabel.autoAlignAxis(.horizontal, toSameAxisOf: shotContainer, withOffset: messageHorizontalOffset)
            
            didSetConstraints = true
        }

        super.updateConstraints()
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let velocity = panGestureRecognizer.velocity(in: self.contentView)
        return fabs(velocity.x) > fabs(velocity.y)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        shotImageView.image = nil
        shotImageView.originalImage = nil
        authorView.alpha = 0
        enabledActions = [.doNothing, .like, .bucket, .comment, .follow]
    }

    // MARK: - Public

    func displayAuthor(_ shouldDisplay: Bool, animated: Bool) {

        self.layoutIfNeeded()
        if animated {
            UIView.animate(withDuration: 1.0, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.configureAuthorView(shouldDisplay)
                self.layoutIfNeeded()
            })
        } else {
            configureAuthorView(shouldDisplay)
        }
    }

    // MARK: - Actions

    func didSwipeCell(_ panGestureRecognizer: UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .began:
            self.delegate?.shotCollectionViewCellDidStartSwiping(self)
        case .ended, .cancelled, .failed:
            let xTranslation = adjustedXTranslation()
            let selectedAction = self.selectedActionForSwipeXTranslation(xTranslation)
            panGestureRecognizer.isEnabled = false
            displayMessageBasedOnAction(selectedAction)
            animateCellAction(selectedAction) { [unowned self] in
                self.swipeCompletion?(selectedAction)
                self.delegate?.shotCollectionViewCellDidEndSwiping(self)
                panGestureRecognizer.isEnabled = true
            }
        default:
            let xTranslation = adjustedXTranslation()
            adjustConstraintsForSwipeXTranslation(xTranslation)
            adjustActionImageViewForXTranslation(xTranslation)
            previousXTranslation = xTranslation
        }
    }

    // MARK: - Private Helpers
    
    fileprivate func adjustedXTranslation() -> CGFloat {
        let likeOffset = likeActionRange.max - 40
        let xTranslation = self.panGestureRecognizer.translation(in: self.contentView).x
        if xTranslation < 0 && (!enabledActions.contains(.comment) && !enabledActions.contains(.follow)) {
            return 0
        } else if xTranslation > 0 && !enabledActions.contains(.like) && !enabledActions.contains(.bucket) {
            return 0
        } else if xTranslation > 0 && !enabledActions.contains(.bucket) && xTranslation >= likeOffset {
            return likeOffset
        } else if xTranslation < 0 && !enabledActions.contains(.follow) && xTranslation <= commentActionRange.min {
            return commentActionRange.min
        }
        
        return xTranslation
    }

    fileprivate func adjustConstraintsForSwipeXTranslation(_ xTranslation: CGFloat) {
        if xTranslation > bucketActionRange.max || xTranslation < followActionRange.min {
            return
        }

        shotImageView.transform = CGAffineTransform.identity.translatedBy(x: xTranslation, y: 0)
        likeImageViewLeftConstraint?.constant = abs(xTranslation) * 0.17
        likeImageViewWidthConstraint?.constant = min(abs(xTranslation * 0.6),
                likeImageView.intrinsicContentSize.width)

        let secondLeftActionWidthConstant = max((abs(xTranslation * 0.6) - likeActionRange.min), 0)
        plusImageViewWidthConstraint?.constant = min(secondLeftActionWidthConstant,
                plusImageView.intrinsicContentSize.width)
        plusImageView.alpha = min((abs(xTranslation) - likeActionRange.min) / 70, 1)

        bucketImageViewWidthConstraint?.constant = min(secondLeftActionWidthConstant,
                bucketImageView.intrinsicContentSize.width)

        let width = min(abs(xTranslation * 0.6), commentImageView.intrinsicContentSize.width)
        commentImageViewWidthConstraint?.constant = width
        commentImageViewRightConstraint?.constant = -((abs(xTranslation) * 0.5) - (width / 2))
        
        followImageViewWidthConstraint?.constant = min(abs(xTranslation * 0.6),
                                                        followImageView.intrinsicContentSize.width)
    }

    fileprivate func adjustActionImageViewForXTranslation(_ xTranslation: CGFloat) {
        switch xTranslation {
        case likeActionRange.min ..< CGFloat.greatestFiniteMagnitude where xTranslation > previousXTranslation && likeImageView.isFirstImageVisible && !liked:
            UIView.animate(animations: {
                self.likeImageView.displaySecondImageView()
            })
        case -CGFloat.infinity ..< likeActionRange.min where xTranslation < previousXTranslation && likeImageView.isSecondImageVisible && !liked:
            UIView.animate(animations: {
                self.likeImageView.displayFirstImageView()
            })
        case bucketActionRange.min ..< CGFloat.greatestFiniteMagnitude where bucketImageView.isFirstImageVisible:
            UIView.animate(animations: {
                self.bucketImageView.displaySecondImageView()
            })
        case -CGFloat.infinity ..< bucketActionRange.min where bucketImageView.isSecondImageVisible:
            UIView.animate(animations: {
                self.bucketImageView.displayFirstImageView()
            })
        case commentActionRange.mid ... commentActionRange.max where commentImageView.isSelfOrSecondImageVisible:
            UIView.animate(animations: {
                self.displayComment()
                self.commentImageView.displayFirstImageView()
            })
        case commentActionRange.min...commentActionRange.mid:
            UIView.animate(animations: {
                self.displayComment()
                self.commentImageView.displaySecondImageView()
            })
        case followActionRange.mid ... followActionRange.max where followImageView.isSelfOrSecondImageVisible:
            UIView.animate(animations: {
                self.displayFollow()
                self.followImageView.displayFirstImageView()
            })
        case -CGFloat.infinity ..< followActionRange.mid:
            UIView.animate(animations: {
                self.followImageView.displaySecondImageView()
            })
        default: break
        }
    }
    
    fileprivate func displayComment() {
        commentImageView.alpha = 1
        followImageView.alpha = 0
    }
    
    fileprivate func displayFollow() {
        commentImageView.alpha = 0
        followImageView.alpha = 1
    }

    fileprivate func selectedActionForSwipeXTranslation(_ xTranslation: CGFloat) -> Action {
        switch xTranslation {
        case likeActionRange.min ... likeActionRange.max:
            return .like
        case likeActionRange.max ..< CGFloat.infinity:
            return .bucket
        case commentActionRange.min ... commentActionRange.mid:
            return .comment
        case -CGFloat.infinity ..< followActionRange.mid:
            return .follow
        default:
            return .doNothing
        }
    }

    fileprivate func animateCellAction(_ action: Action, completion: (() -> ())?) {
        switch action {
        case .like:
            bucketImageView.isHidden = true
            plusImageView.isHidden = true
            commentImageView.isHidden = true
            followImageView.isHidden = true
            viewClass.animateWithDescriptor(ShotCellLikeActionAnimationDescriptor(shotCell: self,
                    swipeCompletion: completion))
        case .bucket:
            commentImageView.isHidden = true
            followImageView.isHidden = true
            viewClass.animateWithDescriptor(ShotCellBucketActionAnimationDescriptor(shotCell: self,
                    swipeCompletion: completion))
        case .comment, .follow:
            likeImageView.isHidden = true
            plusImageView.isHidden = true
            bucketImageView.isHidden = true
            viewClass.animateWithDescriptor(ShotCellCommentActionAnimationDescriptor(shotCell: self,
                    swipeCompletion: completion))
        default:
            viewClass.animateWithDescriptor(ShotCellInitialStateAnimationDescriptor(shotCell: self,
                    swipeCompletion: completion))
        }
    }
    
    fileprivate func displayMessageBasedOnAction(_ action: Action) {
        switch action {
        case .like:
            messageLabel.text = NSLocalizedString("ShotCollectionCell.Like", comment: "Shown when user perform like action")
        case .bucket:
            messageLabel.text = NSLocalizedString("ShotCollectionCell.Bucket", comment: "Shown when user perform add to bucket action")
        case .comment:
            messageLabel.text = NSLocalizedString("ShotCollectionCell.Comment", comment: "Shown when user perform comment action")
        case .follow:
            messageLabel.text = NSLocalizedString("ShotCollectionCell.Follow", comment: "Shown when user perform follow action")
        case .doNothing:
            messageLabel.text = ""
        }
    }

    fileprivate func configureAuthorView(_ shouldDisplay: Bool) {
        authorView.alpha = shouldDisplay ? 1 : 0
        authorView.isHidden = !shouldDisplay
        authorInfoHeightConstraint?.constant = shouldDisplay ? authorInfoHeight : 0
    }
}

extension ShotCollectionViewCell: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith
                           otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

fileprivate extension UIView {
    
    class func animate(animations: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3) {
            animations()
        }
    }
}
