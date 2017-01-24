//
//  ProfileViewController.swift
//  Inbbbox
//
//  Created by Peter Bruz on 23/01/2017.
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import ZFDragableModalTransition
import PromiseKit
import PeekPop

enum ProfileMenuItem: Int {
    case shots, info, projects, buckets
}

class ProfileViewController: UIViewController, Support3DTouch { // Support3DTouch?

    var profileView: ProfileView! {
        return view as? ProfileView
    }

    fileprivate var selectedMenuItem: ProfileMenuItem?

    fileprivate var viewModel: ProfileShotsViewModel!

    fileprivate var indexPathsNeededImageUpdate = [IndexPath]()

    fileprivate var profilePageViewController: ProfilePageViewController?

    internal var peekPop: PeekPop?
    internal var didCheckedSupport3DForOlderDevices = false

    var dismissClosure: (() -> Void)?

    var modalTransitionAnimator: ZFModalTransitionAnimator?

    var userAlreadyFollowed = false

//    override var containsHeader: Bool {
//        return true
//    }

    func isDisplayingUser(_ user: UserType) -> Bool {
        if let userDetailsViewModel = viewModel as? UserDetailsViewModel, userDetailsViewModel.user == user {
            return true
        }
        return false
    }

    fileprivate var isModal: Bool {
        return self.tabBarController?.presentingViewController is UITabBarController ||
            self.navigationController?.presentingViewController?.presentedViewController ==
            self.navigationController && (self.navigationController != nil)
    }

    /// Initialize view controller to show user's or team's details.
    ///
    /// - Note: According to Dribbble API - Team is a particular case of User,
    ///         so if you want to show team's details - pass it as `UserType` with `accountType = .Team`.
    ///
    /// - parameter user: User to initialize view controller with.
    convenience init(user: UserType) {

        guard let accountType = user.accountType, accountType == .Team else {
            self.init()
//            self.init(oneColumnLayoutCellHeightToWidthRatio: SimpleShotCollectionViewCell.heightToWidthRatio,
//                      twoColumnsLayoutCellHeightToWidthRatio: SimpleShotCollectionViewCell.heightToWidthRatio)
            viewModel = UserDetailsViewModel(user: user)
//            viewModel.delegate = self
            title = viewModel.title
            return
        }

        let team = Team(
            identifier: user.identifier,
            name: user.name ?? "",
            username: user.username,
            avatarURL: user.avatarURL,
            createdAt: Date(),
            followersCount: user.followersCount,
            followingsCount: user.followingsCount,
            bio: user.bio,
            location: user.location
        )
        self.init(team: team)
    }

    fileprivate convenience init(team: TeamType) {

        self.init()
//        self.init(oneColumnLayoutCellHeightToWidthRatio: LargeUserCollectionViewCell.heightToWidthRatio,
//                  twoColumnsLayoutCellHeightToWidthRatio: SmallUserCollectionViewCell.heightToWidthRatio)

        viewModel = TeamDetailsViewModel(team: team)
//        viewModel.delegate = self
        title = viewModel.title
    }

    override func loadView() {
        view = ProfileView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        guard let collectionView = collectionView else { return }
//
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.registerClass(SimpleShotCollectionViewCell.self, type: .cell)
//        collectionView.registerClass(SmallUserCollectionViewCell.self, type: .cell)
//        collectionView.registerClass(LargeUserCollectionViewCell.self, type: .cell)
//        collectionView.registerClass(ProfileHeaderView.self, type: .header)

        do { // hides bottom border of navigationBar
            let currentColorMode = ColorModeProvider.current()
            navigationController?.navigationBar.shadowImage = UIImage(color: currentColorMode.navigationBarTint)
            navigationController?.navigationBar.setBackgroundImage(
                UIImage(color: currentColorMode.navigationBarTint),
                for: .default
            )
        }

        setupBackButton()
        setupHeaderView()

        profileView.menuBarView.didSelectItem = { [weak self] menuItem in
            self?.handleMenuItemSelection(menuItem)
        }

        setupProfilePageViewController()

        viewModel.downloadInitialItems()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if selectedMenuItem == nil {
            selectedMenuItem = .shots
            profileView.menuBarView.select(item: .shots)
        }

//        addSupport3DForOlderDevicesIfNeeded(with: self, viewController: self, sourceView: collectionView!)

        guard viewModel.shouldShowFollowButton else { return }

        guard !userAlreadyFollowed else {
            userIsAlreadyFollowed()
            return
        }
        
        checkIfUserIsFollowed()
    }
}


// MARK: UIPageViewControllerDelegate

extension ProfileViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        guard completed, let viewController = pageViewController.viewControllers?.last else { return }

        guard let index = (pageViewController as? ProfilePageViewController)?.internalDataSource?.viewControllers.index(of: viewController) else { return }

        switch index {
        case 0:
            profileView.menuBarView.select(item: .shots)
            selectedMenuItem = .shots
        case 1:
            profileView.menuBarView.select(item: .info)
            selectedMenuItem = .info
        default: break
        }
    }
}

// MARK: Private extension

private extension ProfileViewController {

    func setupBackButton() {
        if isModal {
            let attributedString = NSMutableAttributedString(
                string: NSLocalizedString("Profile.BackButton",
                                          comment: "Back button, user details"),
                attributes: [NSForegroundColorAttributeName: UIColor.white])
            let textAttachment = NSTextAttachment()
            if let image = UIImage(named: "ic-back") {
                textAttachment.image = image
                textAttachment.bounds = CGRect(x: 0, y: -3, width: image.size.width, height: image.size.height)
            }
            let attributedStringWithImage = NSAttributedString(attachment: textAttachment)
            attributedString.replaceCharacters(in: NSRange(location: 0, length: 0),
                                               with: attributedStringWithImage)

            let backButton = UIButton()
            backButton.setAttributedTitle(attributedString, for: .normal)
            backButton.addTarget(self, action: #selector(didTapLeftBarButtonItem), for: .touchUpInside)
            backButton.sizeToFit()

            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        }
    }

    func setupHeaderView() {
        profileView.headerView.avatarView.imageView.loadImageFromURL(viewModel.avatarURL)
        profileView.headerView.button.addTarget(self, action: #selector(didTapFollowButton(_:)), for: .touchUpInside)
        viewModel.shouldShowFollowButton ? profileView.headerView.startActivityIndicator() : (profileView.headerView.shouldShowButton = false)
    }

    func setupProfilePageViewController() {
        // NGRTemp:
        let dataSource: ProfilePageViewControllerDataSource = {
            if let viewModel = viewModel as? UserDetailsViewModel {
                return ProfilePageViewControllerDataSource(viewControllers:
                    [ProfileShotsViewController(user: viewModel.user),
                     ProfileInfoViewController(user: viewModel.user),
                     UIViewController(),
                     UIViewController()]
                )
            }
            return ProfilePageViewControllerDataSource(viewControllers: [])
        }()


        profilePageViewController = ProfilePageViewController(dataSource)
        profilePageViewController?.delegate = self

        guard let profilePageViewController = profilePageViewController else { return }

        addChildViewController(profilePageViewController)
        profileView.childView.addSubview(profilePageViewController.view)
        profilePageViewController.didMove(toParentViewController: self)
        profilePageViewController.view.autoPinEdgesToSuperviewEdges()
//        profilePageViewController.interactionDelegate = self
    }

    dynamic func didTapLeftBarButtonItem() {
        dismissClosure?()
        dismiss(animated: true, completion: nil)
    }

    func checkIfUserIsFollowed() {
        firstly {
            viewModel.isProfileFollowedByMe()
        }.then { followed in
            self.profileView.headerView.userFollowed = followed
        }.then { _ in
            self.profileView.headerView.stopActivityIndicator()
        }.catch { _ in }
    }

    func userIsAlreadyFollowed() {
        profileView.headerView.userFollowed = userAlreadyFollowed
        self.profileView.headerView.stopActivityIndicator()
    }

    func handleMenuItemSelection(_ menuItem: ProfileMenuItem) {

        guard let lastMenuItem = selectedMenuItem, menuItem != selectedMenuItem else { return }

        let pageIndex: Int = {
            switch menuItem {
            case .shots: return 0
            case .info: return 1
            case .projects: return 2
            case .buckets: return 3
            }
        }()
        profilePageViewController?.selectPage(at: pageIndex, scrollDirection: menuItem.rawValue < lastMenuItem.rawValue ? .reverse : .forward)
        selectedMenuItem = menuItem
    }

    dynamic func didTapFollowButton(_: UIButton) {

        if let userFollowed = profileView.headerView.userFollowed {

            profileView.headerView.startActivityIndicator()
            firstly {
                userFollowed ? viewModel.unfollowProfile() : viewModel.followProfile()
            }.then {
                self.profileView.headerView.userFollowed = !userFollowed
            }.always {
                self.profileView.headerView.stopActivityIndicator()
            }.catch { error in
                FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.tryAgain, canBeDismissedByUser: true)
            }
        }
    }
}
