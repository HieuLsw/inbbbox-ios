//
//  ProfileViewController.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import ZFDragableModalTransition
import PromiseKit
import PeekPop

enum ProfileMenuItem: Int {
    case shots, team, info, projects, buckets
}

protocol TriggeringHeaderUpdate: class {
    var shouldHideHeader: (() -> Void)?  { get set }
    var shouldShowHeader: (() -> Void)? { get set }
}

class ProfileViewController: UIViewController {

    var profileView: ProfileView! {
        return view as? ProfileView
    }

    fileprivate var selectedMenuItem: ProfileMenuItem?

    fileprivate var viewModel: ProfileViewModel

    fileprivate var profilePageViewController: ProfilePageViewController?

    var dismissClosure: (() -> Void)?

    var modalTransitionAnimator: ZFModalTransitionAnimator?

    var userAlreadyFollowed = false

    func isDisplayingUser(_ user: UserType) -> Bool {
        return viewModel.user == user
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
    init(user: UserType) {
        viewModel = ProfileViewModel(user: user)
        super.init(nibName: nil, bundle: nil)
        title = viewModel.title
    }

    @available(*, unavailable, message: "Use init(user:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = ProfileView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        do { // hides bottom border of navigationBar
            let currentColorMode = ColorModeProvider.current()
            navigationController?.navigationBar.shadowImage = UIImage(color: currentColorMode.navigationBarTint)
            navigationController?.navigationBar.setBackgroundImage(UIImage(color: currentColorMode.navigationBarTint), for: .default)
        }

        setupBackButton()
        setupHeaderView()
        setupMenu()

        setupProfilePageViewController()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if selectedMenuItem == nil {
            selectedMenuItem = viewModel.menu[0]
            profileView.menuBarView.select(item: viewModel.menu[0])
        }

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

        let profileMenuItem = viewModel.menu[index]
        profileView.menuBarView.select(item: profileMenuItem)
        selectedMenuItem = profileMenuItem
    }
}

// MARK: Private extension

private extension ProfileViewController {

    func setupBackButton() {
        if isModal {
            let attributedString = NSMutableAttributedString(
                string: Localized("Profile.BackButton",
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

    func setupMenu() {
        profileView.menuBarView.setup(with: viewModel.menu.map { ($0, viewModel.badge(forMenuItem: $0)) })

        profileView.menuBarView.didSelectItem = { [weak self] menuItem in
            self?.handleMenuItemSelection(menuItem)
        }
    }

    func setupProfilePageViewController() {
        let profileShotsOrMembersViewController = ProfileShotsOrMembersViewController(user: viewModel.user)
        profileShotsOrMembersViewController.didLoadTeamMembers = { [weak self] count in self?.profileView.menuBarView.updateBadge(for: .team, with: count) }

        let viewControllers: [UIViewController] = viewModel.menu.map {
            switch $0 {
            case .shots, .team: return profileShotsOrMembersViewController
            case .info: return ProfileInfoViewController(user: viewModel.user)
            case .projects: return UIViewController()
            case .buckets: return ProfileBucketsViewController(user: viewModel.user)
            }
        }

        viewControllers.flatMap { $0 as? TriggeringHeaderUpdate }.forEach { viewController in
            viewController.shouldShowHeader = { [weak self] in self?.profileView.toggleHeader(visible: true) }
            viewController.shouldHideHeader = { [weak self] in self?.profileView.toggleHeader(visible: false) }
        }

        let dataSource = ProfilePageViewControllerDataSource(viewControllers: viewControllers)

        profilePageViewController = ProfilePageViewController(dataSource)
        profilePageViewController?.delegate = self

        guard let profilePageViewController = profilePageViewController else { return }

        addChildViewController(profilePageViewController)
        profileView.childView.addSubview(profilePageViewController.view)
        profilePageViewController.didMove(toParentViewController: self)
        profilePageViewController.view.autoPinEdgesToSuperviewEdges()
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
            case .shots, .team: return 0
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
