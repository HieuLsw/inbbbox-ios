//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

struct ShotsCollectionBackgroundViewSpacing {
    
    static let logoDefaultVerticalInset = CGFloat(60)
    static let logoAnimationVerticalInset = CGFloat(160)
    static let logoHeight = CGFloat(30)
    
    static let labelDefaultHeight = CGFloat(21)
    
    static let showingYouDefaultVerticalSpacing = CGFloat(45)
    static let showingYouHiddenVerticalSpacing = CGFloat(60)
    
    static let containerDefaultVerticalSpacing = CGFloat(70)
    
    static let skipButtonBottomInset = CGFloat(119)
}

class ShotsCollectionSourceItem {
    let label: UILabel
    var heightConstraint: NSLayoutConstraint?
    var verticalSpacingConstraint: NSLayoutConstraint?
    var visible: Bool {
        didSet {
            heightConstraint?.constant = visible ? ShotsCollectionBackgroundViewSpacing.labelDefaultHeight : 0
        }
    }
    
    init() {
        label = UILabel()
        heightConstraint = nil
        verticalSpacingConstraint = nil
        visible = false
    }
}

class ShotsCollectionBackgroundView: UIView {

    fileprivate var didSetConstraints = false
    
    let logoImageView = UIImageView(image: UIImage(named: ColorModeProvider.current().logoImageName))
    let containerView = UIView()
    
    let showingYouLabel = UILabel()
    
    let followingItem = ShotsCollectionSourceItem()
    let newTodayItem = ShotsCollectionSourceItem()
    let popularTodayItem = ShotsCollectionSourceItem()
    let debutsItem = ShotsCollectionSourceItem()
    
    var showingYouVerticalConstraint: NSLayoutConstraint?
    var logoVerticalConstraint: NSLayoutConstraint?
    let skipButton = UIButton()

//    MARK: - Life cycle

    convenience init() {
        self.init(frame: CGRect.zero)

        logoImageView.configureForAutoLayout()
        addSubview(logoImageView)
        
        setupItems()
        setupShowingYouLabel()
        setupSkipButton()
        
        showingYouLabel.text = NSLocalizedString("BackgroundView.ShowingYou", comment: "Showing You title")
        showingYouLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        showingYouLabel.textColor = UIColor.RGBA(98, 109, 104, 0.9)
        showingYouLabel.alpha = 0
        addSubview(showingYouLabel)
    }

//    MARK: - UIView

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override func updateConstraints() {

        if !didSetConstraints {
            logoVerticalConstraint = logoImageView.autoPinEdge(toSuperviewEdge: .top, withInset: ShotsCollectionBackgroundViewSpacing.logoDefaultVerticalInset)
            logoImageView.autoAlignAxis(toSuperviewAxis: .vertical)
            showingYouVerticalConstraint = showingYouLabel.autoPinEdge(toSuperviewEdge: .top, withInset: ShotsCollectionBackgroundViewSpacing.showingYouHiddenVerticalSpacing)
            showingYouLabel.autoAlignAxis(toSuperviewAxis: .vertical)
            showingYouLabel.autoSetDimension(.height, toSize: 29)
            containerView.autoPinEdge(toSuperviewEdge: .top, withInset: ShotsCollectionBackgroundViewSpacing.containerDefaultVerticalSpacing)
            containerView.autoAlignAxis(toSuperviewAxis: .vertical)
            containerView.autoSetDimensions(to: CGSize(width: 150, height: 4 * ShotsCollectionBackgroundViewSpacing.labelDefaultHeight))
            let items = [followingItem, newTodayItem, popularTodayItem, debutsItem]
        
            for (index, item) in items.enumerated() {
                item.heightConstraint = item.label.autoSetDimension(.height, toSize: 0)
                item.label.autoSetDimension(.width, toSize: 150)
                item.label.autoAlignAxis(toSuperviewAxis: .vertical)
                if (index == 0) {
                    item.verticalSpacingConstraint = item.label.autoPinEdge(toSuperviewEdge: .top, withInset: -5)
                } else {
                    item.verticalSpacingConstraint = item.label.autoPinEdge(.top, to: .bottom, of: items[index - 1].label, withOffset: -5)
                }
            }
            
            skipButton.autoAlignAxis(toSuperviewAxis: .vertical)
            skipButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: ShotsCollectionBackgroundViewSpacing.skipButtonBottomInset)
            
            didSetConstraints = true
        }

        super.updateConstraints()
    }
}

// Animatable header

extension ShotsCollectionBackgroundView {
    
    func prepareAnimatableContent() {
        followingItem.visible = Settings.StreamSource.Following
        newTodayItem.visible = Settings.StreamSource.NewToday
        popularTodayItem.visible = Settings.StreamSource.PopularToday
        debutsItem.visible = Settings.StreamSource.Debuts
        for item in [followingItem, newTodayItem, popularTodayItem, debutsItem] {
            item.verticalSpacingConstraint?.constant = 0
        }
    }
    
    func availableItems() -> [ShotsCollectionSourceItem] {
        var items = [ShotsCollectionSourceItem]()
        for item in [followingItem, newTodayItem, popularTodayItem, debutsItem] {
            if (item.visible) {
                items.append(item)
            }
        }
        return items
    }
}

fileprivate extension ShotsCollectionBackgroundView {

    func setupItems() {
        followingItem.label.text = NSLocalizedString("SettingsViewModel.Following", comment: "User settings, enable following")
        newTodayItem.label.text = NSLocalizedString("SettingsViewModel.NewToday", comment: "User settings, enable new today")
        popularTodayItem.label.text = NSLocalizedString("SettingsViewModel.Popular", comment: "User settings, enable popular")
        debutsItem.label.text = NSLocalizedString("SettingsViewModel.Debuts", comment: "User settings, enable debuts")
        for item in [followingItem, newTodayItem, popularTodayItem, debutsItem] {
            item.label.textAlignment = .center
            item.label.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightLight)
            item.label.textColor = UIColor.RGBA(143, 142, 148, 1)
            item.label.alpha = 0
            containerView.addSubview(item.label)
        }
        addSubview(containerView)
    }
    
    func setupShowingYouLabel() {
        showingYouLabel.text = NSLocalizedString("BackgroundView.ShowingYou", comment: "Showing You title")
        showingYouLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        showingYouLabel.textColor = UIColor.RGBA(98, 109, 104, 0.9)
        showingYouLabel.alpha = 0
        addSubview(showingYouLabel)
    }
    
    func setupSkipButton() {
        skipButton.setTitle(NSLocalizedString("ShotsOnboardingStateHandler.Skip", comment: "Onboarding user is skipping step"), for: .normal)
        skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightLight)
        skipButton.setTitleColor(UIColor.black, for: .normal)
        skipButton.isHidden = true
        skipButton.alpha = 0
        addSubview(skipButton)
    }
}
