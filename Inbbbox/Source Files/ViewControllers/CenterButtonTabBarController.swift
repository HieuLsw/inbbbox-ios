//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class CenterButtonTabBarController: UITabBarController {

    fileprivate var didSetConstraints = false
    let centerButton = RoundedButton()
    let shotsCollectionViewController = ShotsCollectionViewController()
    let settingsViewController = SettingsViewController()
    var didUpdateTabBarItems = false
    var animatableLikesTabBarItem: UIImageView?
    var animatableBucketsTabBarItem: UIImageView?
    
    fileprivate var currentColorMode = ColorModeProvider.current()

    enum CenterButtonViewControllers: Int {
        case likes = 0
        case buckets = 1
        case shots = 2
        case followees = 3
        case accounts = 4
    }

    override var selectedIndex: Int {
        didSet {
            centerButton.isSelected = selectedViewController == shotsCollectionViewController
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

        tabBar.layer.shadowColor = UIColor(white: 0, alpha: 0.03).cgColor
        tabBar.layer.shadowRadius = 1
        tabBar.layer.shadowOpacity = 0.6

        do { // these two lines hide top border line of tabBar - can't be separated
            tabBar.shadowImage = UIImage()
            tabBar.backgroundImage = UIImage()
        }

        tabBar.isTranslucent = false
        centerButton.configureForAutoLayout()
        
        centerButton.adaptColorMode(currentColorMode)
        centerButton.adjustsImageWhenHighlighted = false
        centerButton.layer.zPosition = 1
        centerButton.addTarget(
            self,
            action: #selector(didTapCenterButton(_:)),
            for: .touchUpInside
        )
        tabBar.addSubview(centerButton)
        centerButton.autoAlignAxis(toSuperviewAxis: .vertical)
        centerButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8.0)
        delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let items = tabBar.items, !didUpdateTabBarItems {
            didUpdateTabBarItems = true
            for tabBarItem in items {
                tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -3)
            }
        }
        tabBar.bringSubview(toFront: centerButton)
        if selectedViewController == shotsCollectionViewController {
            centerButton.isSelected = true
        }
        prepareAnimatableTabBarItems()
    }

// MARK: - Public
    /// Do any additional configuration in situation
    /// where app was launched with 3D Touch shortcut.
    func configureForLaunchingWithForceTouchShortcut() {
        tabBar.alpha = 1.0
        tabBar.isUserInteractionEnabled = true
    }

    func animateTabBarItem(_ item: CenterButtonViewControllers) {
        guard item == .likes || item == .buckets else { return }

        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        bounceAnimation.duration = TimeInterval(0.5)
        bounceAnimation.calculationMode = kCAAnimationCubic

        let itemToAnimate = item == .likes ? animatableLikesTabBarItem : animatableBucketsTabBarItem

        itemToAnimate?.layer.add(bounceAnimation, forKey: nil)

        if let iconImage = itemToAnimate?.image {
            let renderImage = iconImage.withRenderingMode(.alwaysOriginal)
            itemToAnimate?.image = renderImage
            itemToAnimate?.tintColor = .black
        }
    }

//    MARK: - Actions

    func didTapCenterButton(_: UIButton) {
        centerButton.isSelected = true
        selectedViewController = shotsCollectionViewController
    }
}

extension CenterButtonTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        if selectedIndex != CenterButtonViewControllers.shots.rawValue {
            centerButton.isSelected = false
        }
    }
}

extension CenterButtonTabBarController: ColorModeAdaptable {
    func adaptColorMode(_ mode: ColorModeType) {
        
        setupTabBarItem(forViewControllers: viewControllers, forColorMode: mode)
        centerButton.adaptColorMode(mode)
    }
}

private extension CenterButtonTabBarController {

    func tabBarItemWithTitle(_ title: String?, normalImageName: String, selectedImageName:String) -> UITabBarItem {
        
        let image = UIImage(named: normalImageName)?.withRenderingMode(.alwaysOriginal)
        let selectedImage = UIImage(named: selectedImageName)?.withRenderingMode(.alwaysOriginal)

        let tabBarItem = UITabBarItem(
            title: title,
            image: image,
            selectedImage: selectedImage
        )
        
        tabBarItem.accessibilityLabel = title
        
        tabBarItem.setTitleTextAttributes(
            [NSForegroundColorAttributeName: ColorModeProvider.current().tabBarSelectedItemTextColor],
            for: .selected
        )
        tabBarItem.setTitleTextAttributes(
            [NSForegroundColorAttributeName: ColorModeProvider.current().tabBarNormalItemTextColor],
            for: .normal
        )

        tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)

        return tabBarItem
    }

    func prepareAnimatableTabBarItems() {
        guard animatableLikesTabBarItem == nil else { return }

        animatableLikesTabBarItem = tabBar.subviews[CenterButtonViewControllers.likes.rawValue].subviews.first as? UIImageView
        animatableBucketsTabBarItem = tabBar.subviews[CenterButtonViewControllers.buckets.rawValue].subviews.first as? UIImageView
        animatableLikesTabBarItem?.contentMode = .center
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
