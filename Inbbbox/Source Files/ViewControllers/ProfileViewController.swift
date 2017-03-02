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
    case shots, info, projects, buckets
}

protocol ContainingScrollableView: class {
    var scrollContentOffset: (() -> CGPoint)? { get set }
    var scrollableView: UIScrollView { get }
    var didLayoutSubviews: Bool { get set }
}

fileprivate var shotsContext = 0
fileprivate var infoContext = 1
fileprivate var projectsContext = 2
fileprivate var bucketsContext = 3

class ProfileViewController: UIViewController {

    fileprivate enum KeyPath: String {
        case contentOffset
    }

    var profileView: ProfileView! {
        return view as? ProfileView
    }

    var headerHeight = ProfileView.headerInitialHeight

    fileprivate var selectedMenuItem: ProfileMenuItem? = nil {
        didSet {
            guard let item = selectedMenuItem else { return }
            observeContentOffsetForViewController(withPageIndex: item.rawValue)
        }
    }

    fileprivate var viewModel: ProfileViewModel

    fileprivate var profilePageViewController: ProfilePageViewController?

    fileprivate var indexesForRegisteredObservers: [Int] = []

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

        setupBarButtons()
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        hideBottomBorderOfNavigationBar(true)

        if let menuItem = selectedMenuItem {
            observeContentOffsetForViewController(withPageIndex: menuItem.rawValue)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        removeAllContentOffsetObservers()
        hideBottomBorderOfNavigationBar(false)
        super.viewWillDisappear(animated)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        guard keyPath == KeyPath.contentOffset.rawValue else { return }

        guard
            (context == &shotsContext && selectedMenuItem == .shots) ||
            (context == &infoContext && selectedMenuItem == .info) ||
            (context == &projectsContext && selectedMenuItem == .projects) ||
            (context == &bucketsContext && selectedMenuItem == .buckets)
        else { return }

        guard
            let menuItem = selectedMenuItem,
            let viewController = viewControllerContainingScrollableView(atPageWithIndex: menuItem.rawValue),
            viewController.didLayoutSubviews
        else { return }

        guard
            let newOffset = change?[.newKey] as? CGPoint,
            let oldoffset = change?[.oldKey] as? CGPoint,
            newOffset.y != oldoffset.y
        else { return }

        profileView.setHeaderHeight(value: -newOffset.y)
        headerHeight = -newOffset.y
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

    func setupBarButtons() {
        if isModal {
            let attributedString = NSMutableAttributedString(
                string: Localized("Profile.BackButton", comment: "Back button, user details"),
                attributes: [NSForegroundColorAttributeName: UIColor.white])
            let textAttachment = NSTextAttachment()
            if let image = UIImage(named: "ic-back") {
                textAttachment.image = image
                textAttachment.bounds = CGRect(x: 0, y: -3, width: image.size.width, height: image.size.height)
            }
            let attributedStringWithImage = NSAttributedString(attachment: textAttachment)
            attributedString.replaceCharacters(in: NSRange(location: 0, length: 0), with: attributedStringWithImage)

            let backButton = UIButton()
            backButton.setAttributedTitle(attributedString, for: .normal)
            backButton.addTarget(self, action: #selector(didTapLeftBarButtonItem), for: .touchUpInside)
            backButton.sizeToFit()

            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic-flaguser"), style: .plain, target: self, action: #selector(didTapFlagUser(_:)))

    }

    func setupHeaderView() {
        profileView.headerView.avatarView.imageView.loadImageFromURL(viewModel.avatarURL)
        profileView.headerView.badge = viewModel.user.isPro ? .pro : nil
        profileView.headerView.badge = viewModel.user.accountType == .Team ? .team : profileView.headerView.badge
        profileView.headerView.button.addTarget(self, action: #selector(didTapFollowButton(_:)), for: .touchUpInside)
        profileView.headerView.backgroundImageView.image = viewModel.backgroundImage
        viewModel.shouldShowFollowButton ? profileView.headerView.startActivityIndicator() : (profileView.headerView.shouldShowButton = false)
    }

    func setupMenu() {
        profileView.menuBarView.setup(with: viewModel.menu.map { ($0, viewModel.badge(forMenuItem: $0)) })

        profileView.menuBarView.didSelectItem = { [weak self] menuItem in
            self?.handleMenuItemSelection(menuItem)
        }
    }

    func setupProfilePageViewController() {
        
        let viewControllers: [UIViewController] = viewModel.menu.map {
            switch $0 {
            case .shots: return ProfileShotsViewController(user: viewModel.user)
            case .info: return ProfileInfoViewController(user: viewModel.user)
            case .projects: return ProfileProjectsOrBucketsViewController(user: viewModel.user, type: .projects)
            case .buckets: return ProfileProjectsOrBucketsViewController(user: viewModel.user, type: .buckets)
            }
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

    func observeContentOffsetForViewController(withPageIndex index: Int) {
        removeAllContentOffsetObservers()

        guard let scrollableView = viewControllerContainingScrollableView(atPageWithIndex: index)?.scrollableView else { return }

        let keyPath = KeyPath.contentOffset.rawValue
        let options: NSKeyValueObservingOptions = [.old, .new]
        switch index {
        case ProfileMenuItem.shots.rawValue: scrollableView.addObserver(self, forKeyPath: keyPath, options: options, context: &shotsContext)
        case ProfileMenuItem.info.rawValue: scrollableView.addObserver(self, forKeyPath: keyPath, options: options, context: &infoContext)
        case ProfileMenuItem.projects.rawValue: scrollableView.addObserver(self, forKeyPath: keyPath, options: options, context: &projectsContext)
        case ProfileMenuItem.buckets.rawValue: scrollableView.addObserver(self, forKeyPath: keyPath, options: options, context: &bucketsContext)
        default: break
        }

        indexesForRegisteredObservers.append(index)
        viewControllerContainingScrollableView(atPageWithIndex: index)?.scrollContentOffset = { CGPoint(x: 0, y: -self.headerHeight) }
    }

    func removeAllContentOffsetObservers() {
        indexesForRegisteredObservers.forEach { index in
            viewControllerContainingScrollableView(atPageWithIndex: index)?.scrollableView.removeObserver(self, forKeyPath: KeyPath.contentOffset.rawValue)
        }

        indexesForRegisteredObservers.removeAll()
    }

    dynamic func didTapLeftBarButtonItem() {
        if navigationController?.viewControllers.first == self {
            dismissClosure?()
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
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

    dynamic func didTapFlagUser(_: UIButton) {
        UsersRequester().block(user: viewModel.user) // NGRTodo: fix before CR - move and use properly in ViewModel
    }

    func hideBottomBorderOfNavigationBar(_ value: Bool) {
        let image = value ? UIImage(color: ColorModeProvider.current().profileNavigationBarTint) : nil
        navigationController?.navigationBar.shadowImage = image
        navigationController?.navigationBar.setBackgroundImage(image, for: .default)
    }

    func viewControllerContainingScrollableView(atPageWithIndex index: Int) -> ContainingScrollableView? {
        let viewControllers = (profilePageViewController?.dataSource as? ProfilePageViewControllerDataSource)?.viewControllers
        return viewControllers?[index] as? ContainingScrollableView
    }
}
