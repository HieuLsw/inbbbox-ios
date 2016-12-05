//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class CenterButtonTabBarController: UITabBarController {

    private var didSetConstraints = false
    let centerButton = RoundedButton()
    let shotsCollectionViewController = ShotsCollectionViewController()
    let settingsViewController = SettingsViewController()
    var didUpdateTabBarItems = false
    var animatableLikesTabBarItem: UIImageView?
    var animatableBucketsTabBarItem: UIImageView?
    
    private var currentColorMode = ColorModeProvider.current()

    enum CenterButtonViewControllers: Int {
        case Likes = 0
        case Buckets = 1
        case Shots = 2
        case Followees = 3
        case Accounts = 4
    }

    override var selectedIndex: Int {
        didSet {
            centerButton.selected = selectedViewController == shotsCollectionViewController
        }
    }

    convenience init() {
        self.init(nibName: nil, bundle: nil)

        let likesViewController = UINavigationController(rootViewController: SimpleShotsCollectionViewController())
        let bucketsViewController =  UINavigationController(rootViewController: BucketsCollectionViewController())

        let followeesViewController = UINavigationController(
            rootViewController: FolloweesCollectionViewController(
                oneColumnLayoutCellHeightToWidthRatio:
                LargeUserCollectionViewCell.heightToWidthRatio,
                twoColumnsLayoutCellHeightToWidthRatio:
                SmallUserCollectionViewCell.heightToWidthRatio
            )
        )

        let settingsViewController = UINavigationController(rootViewController: self.settingsViewController)

        viewControllers = [
            likesViewController,
            bucketsViewController,
            shotsCollectionViewController,
            followeesViewController,
            settingsViewController
        ]
        
        setupTabBarItem(forViewControllers: viewControllers, forColorMode: ColorModeProvider.current())
        selectedViewController = shotsCollectionViewController
    }

//    MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.layer.shadowColor = UIColor(white: 0, alpha: 0.03).CGColor
        tabBar.layer.shadowRadius = 1
        tabBar.layer.shadowOpacity = 0.6

        do { // these two lines hide top border line of tabBar - can't be separated
            tabBar.shadowImage = UIImage()
            tabBar.backgroundImage = UIImage()
        }

        tabBar.translucent = false
        centerButton.configureForAutoLayout()
        
        centerButton.adaptColorMode(currentColorMode)
        centerButton.adjustsImageWhenHighlighted = false
        centerButton.layer.zPosition = 1
        centerButton.addTarget(
            self,
            action: #selector(didTapCenterButton(_:)),
            forControlEvents: .TouchUpInside
        )
        tabBar.addSubview(centerButton)
        centerButton.autoAlignAxisToSuperviewAxis(.Vertical)
        centerButton.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 8.0)
        delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let items = tabBar.items where !didUpdateTabBarItems {
            didUpdateTabBarItems = true
            for tabBarItem in items {
                tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -3)
            }
        }
        tabBar.bringSubviewToFront(centerButton)
        if selectedViewController == shotsCollectionViewController {
            centerButton.selected = true
        }
        prepareAnimatableTabBarItems()
    }

// MARK: - Public
    /// Do any additional configuration in situation
    /// where app was launched with 3D Touch shortcut.
    func configureForLaunchingWithForceTouchShortcut() {
        tabBar.alpha = 1.0
        tabBar.userInteractionEnabled = true
    }

    func animateTabBarItem(item: CenterButtonViewControllers) {
        guard item == .Likes || item == .Buckets else { return }

        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        bounceAnimation.duration = NSTimeInterval(0.5)
        bounceAnimation.calculationMode = kCAAnimationCubic

        let itemToAnimate = item == .Likes ? animatableLikesTabBarItem : animatableBucketsTabBarItem

        itemToAnimate?.layer.addAnimation(bounceAnimation, forKey: nil)

        if let iconImage = itemToAnimate?.image {
            let renderImage = iconImage.imageWithRenderingMode(.AlwaysOriginal)
            itemToAnimate?.image = renderImage
            itemToAnimate?.tintColor = .blackColor()
        }
    }

//    MARK: - Actions

    func didTapCenterButton(_: UIButton) {
        centerButton.selected = true
        selectedViewController = shotsCollectionViewController
    }
}

extension CenterButtonTabBarController: UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController,
                          didSelectViewController viewController: UIViewController) {
        if selectedIndex != CenterButtonViewControllers.Shots.rawValue {
            centerButton.selected = false
        }
    }
}

extension CenterButtonTabBarController: ColorModeAdaptable {
    func adaptColorMode(mode: ColorModeType) {
        
        setupTabBarItem(forViewControllers: viewControllers, forColorMode: mode)
        centerButton.adaptColorMode(mode)
    }
}

private extension CenterButtonTabBarController {

    func tabBarItemWithTitle(title: String?, normalImageName: String, selectedImageName:String) -> UITabBarItem {
        
        let image = UIImage(named: normalImageName)?.imageWithRenderingMode(.AlwaysOriginal)
        let selectedImage = UIImage(named: selectedImageName)?.imageWithRenderingMode(.AlwaysOriginal)

        let tabBarItem = UITabBarItem(
            title: title,
            image: image,
            selectedImage: selectedImage
        )
        
        tabBarItem.accessibilityLabel = title
        
        tabBarItem.setTitleTextAttributes(
            [NSForegroundColorAttributeName: ColorModeProvider.current().tabBarSelectedItemTextColor],
            forState: .Selected
        )
        tabBarItem.setTitleTextAttributes(
            [NSForegroundColorAttributeName: ColorModeProvider.current().tabBarNormalItemTextColor],
            forState: .Normal
        )

        tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)

        return tabBarItem
    }

    func prepareAnimatableTabBarItems() {
        guard animatableLikesTabBarItem == nil else { return }

        animatableLikesTabBarItem = tabBar.subviews[CenterButtonViewControllers.Likes.rawValue].subviews.first as? UIImageView
        animatableBucketsTabBarItem = tabBar.subviews[CenterButtonViewControllers.Buckets.rawValue].subviews.first as? UIImageView
        animatableLikesTabBarItem?.contentMode = .Center
    }
    
    func setupTabBarItem(forViewControllers viewControllers: [UIViewController]?, forColorMode mode: ColorModeType) {
        guard let viewControllers = viewControllers else {
            return
        }
        
        for viewController in viewControllers {
            guard let firstViewController = (viewController as? UINavigationController)?.viewControllers.first else {
                continue
            }
            
            switch firstViewController {
            case let likesViewController as SimpleShotsCollectionViewController:
                likesViewController.tabBarItem = tabBarItemWithTitle(
                    nil,
                    normalImageName: mode.tabBarLikesNormalImageName,
                    selectedImageName: mode.tabBarLikesSelectedImageName
                )
                likesViewController.adaptColorMode(mode)
            case let bucketsViewController as BucketsCollectionViewController:
                bucketsViewController.tabBarItem = tabBarItemWithTitle(
                    nil,
                    normalImageName: mode.tabBarBucketsNormalImageName,
                    selectedImageName: mode.tabBarBucketsSelectedImageName
                )
                bucketsViewController.adaptColorMode(mode)
            case let followeesViewController as FolloweesCollectionViewController:
                followeesViewController.tabBarItem = tabBarItemWithTitle(
                    nil,
                    normalImageName: mode.tabBarFollowingNormalImageName,
                    selectedImageName: mode.tabBarFollowingSelectedImageName
                )
                followeesViewController.adaptColorMode(mode)
            case let settingsViewController as SettingsViewController:
                settingsViewController.tabBarItem = tabBarItemWithTitle(
                    nil,
                    normalImageName: mode.tabBarSettingsNormalImageName,
                    selectedImageName: mode.tabBarSettingsSelectedImageName
                )
                settingsViewController.adaptColorMode(mode)
            default:
                break
            }
        }
    }
}
