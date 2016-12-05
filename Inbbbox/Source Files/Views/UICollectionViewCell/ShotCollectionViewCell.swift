//
// Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

protocol ShotCollectionViewCellDelegate: class {
    func shotCollectionViewCellDidStartSwiping(shotCollectionViewCell: ShotCollectionViewCell)

    func shotCollectionViewCellDidEndSwiping(shotCollectionViewCell: ShotCollectionViewCell)
}

class ShotCollectionViewCell: UICollectionViewCell {

    enum Action {
        case DoNothing
        case Like
        case Bucket
        case Comment
        case Follow
    }

    let shotImageView = ShotImageView.newAutoLayoutView()
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
        l.font = UIFont.helveticaFont(.NeueBold, size: 15)
        l.textColor = .whiteColor()
        l.textAlignment = .Center
        return l
    }()
    

    let shotContainer = UIView.newAutoLayoutView()
    let authorView = ShotAuthorCompactView.newAutoLayoutView()
    var configureForDisplayingAuthorView = false

    private(set) var likeImageViewLeftConstraint: NSLayoutConstraint?
    private(set) var likeImageViewWidthConstraint: NSLayoutConstraint?
    private(set) var plusImageViewWidthConstraint: NSLayoutConstraint?
    private(set) var bucketImageViewWidthConstraint: NSLayoutConstraint?
    private(set) var commentImageViewRightConstraint: NSLayoutConstraint?
    private(set) var commentImageViewWidthConstraint: NSLayoutConstraint?
    private(set) var followImageViewWidthConstraint: NSLayoutConstraint?
    private var authorInfoHeightConstraint: NSLayoutConstraint?

    var viewClass = UIView.self
    var swipeCompletion: (Action -> Void)?
    weak var delegate: ShotCollectionViewCellDelegate?
    var isRegisteredTo3DTouch = false

    private let panGestureRecognizer = UIPanGestureRecognizer()

    private let likeActionRange = ActionRange(min: 40, max: 120)
    private let bucketActionRange = ActionRange(min: 120, max: 170)
    private let commentActionRange = ActionRange(min: -80, max: 0)
    private let followActionRange = ActionRange(min: -170, max: -80)
    private let authorInfoHeight: CGFloat = 25

    private var didSetConstraints = false
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
    var enabledActions:[Action] = [.DoNothing, .Like, .Bucket, .Comment, .Follow]

    // MARK: - Life cycle

    @available(*, unavailable, message = "Use init(frame:) instead")
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

    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }

    override func updateConstraints() {

        if !didSetConstraints {
            shotContainer.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
            shotContainer.autoPinEdge(.Bottom, toEdge: .Top, ofView: authorView)
            let height = configureForDisplayingAuthorView ? authorInfoHeight : 0

            authorInfoHeightConstraint = authorView.autoSetDimension(.Height, toSize: height)
            authorView.autoPinEdgeToSuperviewEdge(.Leading, withInset: 2)
            authorView.autoPinEdgeToSuperviewEdge(.Trailing)
            authorView.autoPinEdgeToSuperviewEdge(.Bottom)

            shotImageView.autoPinEdgesToSuperviewEdges()

            likeImageViewWidthConstraint = likeImageView.autoSetDimension(.Width, toSize: 0)
            likeImageView.autoConstrainAttribute(.Height,
                                                 toAttribute: .Width,
                                                 ofView: likeImageView,
                                                 withMultiplier: likeImageView.intrinsicContentSize().height /
                                                                 likeImageView.intrinsicContentSize().width)
            likeImageViewLeftConstraint = likeImageView.autoPinEdgeToSuperviewEdge(.Left)
            likeImageView.autoAlignAxisToSuperviewAxis(.Horizontal)

            plusImageViewWidthConstraint = plusImageView.autoSetDimension(.Width, toSize: 0)
            plusImageView.autoConstrainAttribute(.Height, toAttribute: .Width, ofView: plusImageView,
                    withMultiplier: plusImageView.intrinsicContentSize().height /
                            plusImageView.intrinsicContentSize().width)
            plusImageView.autoPinEdge(.Left, toEdge: .Right, ofView: likeImageView, withOffset: 15)
            plusImageView.autoAlignAxisToSuperviewAxis(.Horizontal)

            bucketImageViewWidthConstraint = bucketImageView.autoSetDimension(.Width, toSize: 0)
            bucketImageView.autoConstrainAttribute(.Height, toAttribute: .Width, ofView: bucketImageView,
                    withMultiplier: bucketImageView.intrinsicContentSize().height /
                            bucketImageView.intrinsicContentSize().width)
            bucketImageView.autoPinEdge(.Left, toEdge: .Right, ofView: plusImageView, withOffset: 15)
            bucketImageView.autoAlignAxisToSuperviewAxis(.Horizontal)

            commentImageViewWidthConstraint = commentImageView.autoSetDimension(.Width, toSize: 0)
            commentImageView.autoConstrainAttribute(.Height, toAttribute: .Width, ofView: commentImageView,
                    withMultiplier: commentImageView.intrinsicContentSize().height /
                            commentImageView.intrinsicContentSize().width)
            commentImageViewRightConstraint = commentImageView.autoPinEdgeToSuperviewEdge(.Right)
            commentImageView.autoAlignAxisToSuperviewAxis(.Horizontal)
            
            followImageViewWidthConstraint = followImageView.autoSetDimension(.Width, toSize: 0)
            followImageView.autoConstrainAttribute(.Height, toAttribute: .Width, ofView: followImageView,
                    withMultiplier: followImageView.intrinsicContentSize().height /
                            followImageView.intrinsicContentSize().width)
            followImageView.autoAlignAxis(.Vertical, toSameAxisOfView: commentImageView)
            followImageView.autoAlignAxisToSuperviewAxis(.Horizontal)
            
            gifLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 10)
            gifLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 10)

            messageLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            let messageHorizontalOffset = followImageView.intrinsicContentSize().height
            messageLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: shotContainer, withOffset: messageHorizontalOffset)
            
            didSetConstraints = true
        }

        super.updateConstraints()
    }

    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let velocity = panGestureRecognizer.velocityInView(self.contentView)
        return fabs(velocity.x) > fabs(velocity.y)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        shotImageView.image = nil
        shotImageView.originalImage = nil
        authorView.alpha = 0
        enabledActions = [.DoNothing, .Like, .Bucket, .Comment, .Follow]
    }

    // MARK: - Public

    func displayAuthor(shouldDisplay: Bool, animated: Bool) {

        self.layoutIfNeeded()
        if animated {
            UIView.animate(duration: 1.0, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.configureAuthorView(shouldDisplay)
                self.layoutIfNeeded()
            })
        } else {
            configureAuthorView(shouldDisplay)
        }
    }

    // MARK: - Actions

    func didSwipeCell(panGestureRecognizer: UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .Began:
            self.delegate?.shotCollectionViewCellDidStartSwiping(self)
        case .Ended, .Cancelled, .Failed:
            let xTranslation = adjustedXTranslation()
            let selectedAction = self.selectedActionForSwipeXTranslation(xTranslation)
            panGestureRecognizer.enabled = false
            displayMessageBasedOnAction(selectedAction)
            animateCellAction(selectedAction) { [unowned self] in
                self.swipeCompletion?(selectedAction)
                self.delegate?.shotCollectionViewCellDidEndSwiping(self)
                panGestureRecognizer.enabled = true
            }
        default:
            let xTranslation = adjustedXTranslation()
            adjustConstraintsForSwipeXTranslation(xTranslation)
            adjustActionImageViewForXTranslation(xTranslation)
            previousXTranslation = xTranslation
        }
    }

    // MARK: - Private Helpers
    
    private func adjustedXTranslation() -> CGFloat {
        let likeOffset = likeActionRange.max - 40
        let xTranslation = self.panGestureRecognizer.translationInView(self.contentView).x
        if xTranslation < 0 && (!enabledActions.contains(.Comment) && !enabledActions.contains(.Follow)) {
            return 0
        } else if xTranslation > 0 && !enabledActions.contains(.Like) && !enabledActions.contains(.Bucket) {
            return 0
        } else if xTranslation > 0 && !enabledActions.contains(.Bucket) && xTranslation >= likeOffset {
            return likeOffset
        } else if xTranslation < 0 && !enabledActions.contains(.Follow) && xTranslation <= commentActionRange.min {
            return commentActionRange.min
        }
        
        return xTranslation
    }

    private func adjustConstraintsForSwipeXTranslation(xTranslation: CGFloat) {
        if xTranslation > bucketActionRange.max || xTranslation < followActionRange.min {
            return
        }

        shotImageView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, xTranslation, 0)
        likeImageViewLeftConstraint?.constant = abs(xTranslation) * 0.17
        likeImageViewWidthConstraint?.constant = min(abs(xTranslation * 0.6),
                likeImageView.intrinsicContentSize().width)

        let secondLeftActionWidthConstant = max((abs(xTranslation * 0.6) - likeActionRange.min), 0)
        plusImageViewWidthConstraint?.constant = min(secondLeftActionWidthConstant,
                plusImageView.intrinsicContentSize().width)
        plusImageView.alpha = min((abs(xTranslation) - likeActionRange.min) / 70, 1)

        bucketImageViewWidthConstraint?.constant = min(secondLeftActionWidthConstant,
                bucketImageView.intrinsicContentSize().width)

        let width = min(abs(xTranslation * 0.6), commentImageView.intrinsicContentSize().width)
        commentImageViewWidthConstraint?.constant = width
        commentImageViewRightConstraint?.constant = -((abs(xTranslation) * 0.5) - (width / 2))
        
        followImageViewWidthConstraint?.constant = min(abs(xTranslation * 0.6),
                                                        followImageView.intrinsicContentSize().width)
    }

    private func adjustActionImageViewForXTranslation(xTranslation: CGFloat) {
        switch xTranslation {
        case likeActionRange.min ..< CGFloat.max where xTranslation > previousXTranslation && likeImageView.isFirstImageVisible && !liked:
            UIView.animate(animations: {
                self.likeImageView.displaySecondImageView()
            })
        case -CGFloat.infinity ..< likeActionRange.min where xTranslation < previousXTranslation && likeImageView.isSecondImageVisible && !liked:
            UIView.animate(animations: {
                self.likeImageView.displayFirstImageView()
            })
        case bucketActionRange.min ..< CGFloat.max where bucketImageView.isFirstImageVisible:
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
    
    private func displayComment() {
        commentImageView.alpha = 1
        followImageView.alpha = 0
    }
    
    private func displayFollow() {
        commentImageView.alpha = 0
        followImageView.alpha = 1
    }

    private func selectedActionForSwipeXTranslation(xTranslation: CGFloat) -> Action {
        switch xTranslation {
        case likeActionRange.min ... likeActionRange.max:
            return .Like
        case likeActionRange.max ..< CGFloat.infinity:
            return .Bucket
        case commentActionRange.min ... commentActionRange.mid:
            return .Comment
        case -CGFloat.infinity ..< followActionRange.mid:
            return .Follow
        default:
            return .DoNothing
        }
    }

    private func animateCellAction(action: Action, completion: (() -> ())?) {
        switch action {
        case .Like:
            bucketImageView.hidden = true
            plusImageView.hidden = true
            commentImageView.hidden = true
            followImageView.hidden = true
            viewClass.animateWithDescriptor(ShotCellLikeActionAnimationDescriptor(shotCell: self,
                    swipeCompletion: completion))
        case .Bucket:
            commentImageView.hidden = true
            followImageView.hidden = true
            viewClass.animateWithDescriptor(ShotCellBucketActionAnimationDescriptor(shotCell: self,
                    swipeCompletion: completion))
        case .Comment, .Follow:
            likeImageView.hidden = true
            plusImageView.hidden = true
            bucketImageView.hidden = true
            viewClass.animateWithDescriptor(ShotCellCommentActionAnimationDescriptor(shotCell: self,
                    swipeCompletion: completion))
        default:
            viewClass.animateWithDescriptor(ShotCellInitialStateAnimationDescriptor(shotCell: self,
                    swipeCompletion: completion))
        }
    }
    
    private func displayMessageBasedOnAction(action: Action) {
        switch action {
        case .Like:
            messageLabel.text = NSLocalizedString("ShotCollectionCell.Like", comment: "Shown when user perform like action")
        case .Bucket:
            messageLabel.text = NSLocalizedString("ShotCollectionCell.Bucket", comment: "Shown when user perform add to bucket action")
        case .Comment:
            messageLabel.text = NSLocalizedString("ShotCollectionCell.Comment", comment: "Shown when user perform comment action")
        case .Follow:
            messageLabel.text = NSLocalizedString("ShotCollectionCell.Follow", comment: "Shown when user perform follow action")
        case .DoNothing:
            messageLabel.text = ""
        }
    }

    private func configureAuthorView(shouldDisplay: Bool) {
        authorView.alpha = shouldDisplay ? 1 : 0
        authorView.hidden = !shouldDisplay
        authorInfoHeightConstraint?.constant = shouldDisplay ? authorInfoHeight : 0
    }
}

extension ShotCollectionViewCell: Reusable {

    static var reuseIdentifier: String {
        return "ShotCollectionViewCellIdentifier"
    }
}

extension ShotCollectionViewCell: UIGestureRecognizerDelegate {

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWithGestureRecognizer
                           otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
