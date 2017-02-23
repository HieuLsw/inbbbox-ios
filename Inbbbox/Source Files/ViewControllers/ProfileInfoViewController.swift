//
//  ProfileInfoViewController.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Haneke
import PromiseKit
import UIKit
import ZFDragableModalTransition

final class ProfileInfoViewController: UIViewController, ContainingScrollableView {

    fileprivate let viewModel: ProfileInfoViewModel

    fileprivate var currentColorMode = ColorModeProvider.current()

    fileprivate var currentContainer = [ShotType]()
    fileprivate var modalTransitionAnimator: ZFModalTransitionAnimator?
    
    fileprivate var profileInfoView: ProfileInfoView! {
        return view as? ProfileInfoView
    }
    
    var scrollableView: UIScrollView {
        return profileInfoView.scrollView
    }
    
    var scrollContentOffset: (() -> CGPoint)?
    var didLayoutSubviews = false

    init(user: UserType) {
        viewModel = ProfileInfoViewModel(user: user)
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }

    @available(*, unavailable, message: "Use init(user:) instead")
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    @available(*, unavailable, message: "Use init(user:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        profileInfoView.scrollView.updateInsets(top: ProfileView.headerInitialHeight)

        viewModel.downloadInitialItems()

        setupUI()
        setupTeamsCollectionView()
        setupTeamMembersTableView()
        setupLikedShotsTableView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileInfoView.teamsCollectionViewFlowLayout.itemSize = CGSize(width: profileInfoView.frame.size.width / 2, height: 65)

        didLayoutSubviews = true
        adjustScrollView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewModel.likedShotsCount == 0 && viewModel.teamsCount == 0 && viewModel.teamMembersCount == 0 {
            profileInfoView.scrollView.updateInsets(bottom: profileInfoView.scrollView.frame.height)
        }
        
        if let offset = scrollContentOffset?() {
            profileInfoView.scrollView.contentOffset = offset
        }
    }

    override func loadView() {
        view = ProfileInfoView(frame: .zero)
    }

    private func setupTeamsCollectionView() {
        profileInfoView.teamsCollectionView.delegate = self
        profileInfoView.teamsCollectionView.dataSource = self
        profileInfoView.teamsCollectionView.isScrollEnabled = false
        profileInfoView.teamsCollectionView.register(TeamCollectionViewCell.self, forCellWithReuseIdentifier: TeamCollectionViewCell.identifier)
        profileInfoView.teamsCollectionView.register(TeamsCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: TeamsCollectionHeaderView.identifier)
    }

    private func setupLikedShotsTableView() {
        setupTableView(profileInfoView.likedShotsTableView)
    }

    private func setupTeamMembersTableView() {
        setupTableView(profileInfoView.teamMembersTableView)
    }
    
    private func setupTableView(_ tableView: UITableView) {
        tableView.dataSource = self
        tableView.register(CarouselCell.self, forCellReuseIdentifier: CarouselCell.identifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 165
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
    }
    
    fileprivate func setupUI() {
        profileInfoView.shotsAmountView.valueLabel.text = viewModel.shotsCount
        profileInfoView.followersAmountView.valueLabel.text = viewModel.followersCount
        profileInfoView.followingAmountView.valueLabel.text = viewModel.followingsCount
        profileInfoView.locationView.locationLabel.text = viewModel.location
        profileInfoView.bioLabel.setText(viewModel.bio)
        profileInfoView.locationView.isHidden = viewModel.shouldHideLocation
        profileInfoView.teamsCollectionView.isHidden = viewModel.shouldHideTeams
        profileInfoView.teamMembersTableView.isHidden = viewModel.shouldHideTeamMembers
    }

}

extension ProfileInfoViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamCollectionViewCell.identifier, for: indexPath) as! TeamCollectionViewCell
        cell.nameLabel.text = viewModel.team(forIndex: indexPath.row).name
        guard let url = viewModel.team(forIndex: indexPath.row).avatarURL else { return cell }
        cell.logoImageView.hnk_setImageFromURL(url, format: Format<UIImage>(name: TeamCollectionViewCell.identifier))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: TeamsCollectionHeaderView.identifier, for: indexPath)
        return header
    }

}

extension ProfileInfoViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == viewModel.itemsCount - 1 && indexPath.row > 30) {
            viewModel.downloadItemsForNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let team = viewModel.team(forIndex: indexPath.item)
        let profileViewController = ProfileViewController(user: team)
        profileViewController.hidesBottomBarWhenPushed = true
        profileViewController.userAlreadyFollowed = true
        navigationController?.pushViewController(profileViewController, animated: true)
    }

}

extension ProfileInfoViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == profileInfoView.teamMembersTableView ? viewModel.teamMembersCount : viewModel.likedShotsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = prepareCell(at: indexPath, in: tableView)
        return cell
    }

}

extension ProfileInfoViewController {

    func prepareCell(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(CarouselCell.self)
        cell.adaptColorMode(currentColorMode)
        cell.selectionStyle = .none
        cell.delegate = self
        
        if tableView == profileInfoView.teamMembersTableView {
            let teamMember = viewModel.member(forIndex: indexPath.row)
            cell.titleLabel.text = teamMember.name
            cell.backgroundLabel.text = teamMember.name
            cell.shots = viewModel.shots(forIndex: indexPath.row)
        } else if tableView == profileInfoView.likedShotsTableView {
            cell.titleLabel.text = Localized("ProfileInfoView.RecentLikes", comment: "")
            cell.backgroundLabel.text = Localized("ProfileInfoView.RecentLikes", comment: "")
            cell.shots = viewModel.userLikedShots
        }

        return cell
    }
    
    func adjustScrollView() {
        guard profileInfoView.frame.height > 0 else { return }

        if viewModel.likedShotsCount == 0 && viewModel.teamsCount == 0 && viewModel.teamMembersCount == 0 {
            profileInfoView.scrollView.updateInsets(bottom: profileInfoView.scrollView.frame.height)
        } else if profileInfoView.scrollView.contentSize.height < profileInfoView.scrollView.frame.height {
            profileInfoView.scrollView.updateInsets(bottom: profileInfoView.scrollView.frame.height - profileInfoView.scrollView.contentSize.height)
        } else {
            profileInfoView.scrollView.updateInsets(bottom: 0)
        }
        guard let offset = self.scrollContentOffset?() else { return }
        profileInfoView.scrollView.contentOffset = offset
    }
}

extension ProfileInfoViewController: BaseCollectionViewViewModelDelegate {

    func viewModelDidLoadInitialItems() {
        profileInfoView.teamsCollectionView.reloadData()
        profileInfoView.teamMembersTableView.reloadData()
        profileInfoView.likedShotsTableView.reloadData()
        setupUI()
        profileInfoView.updateLayout()
        profileInfoView.teamsCollectionView.layoutIfNeeded()
        profileInfoView.teamMembersTableView.layoutIfNeeded()
        profileInfoView.likedShotsTableView.layoutIfNeeded()
        adjustScrollView()
    }

    func viewModelDidFailToLoadInitialItems(_ error: Error) {
        profileInfoView.teamsCollectionView.reloadData()
        profileInfoView.teamsCollectionView.layoutIfNeeded()
        if let offset = self.scrollContentOffset?() {
            self.profileInfoView.scrollView.contentOffset = offset
        }
        
        if viewModel.isTeamsEmpty {
            guard let visibleViewController = navigationController?.visibleViewController else { return }
            FlashMessage.sharedInstance.showNotification(inViewController: visibleViewController, title: FlashMessageTitles.tryAgain, canBeDismissedByUser: true)
        }
    }

    func viewModelDidFailToLoadItems(_ error: Error) {
        guard let visibleViewController = navigationController?.visibleViewController else { return }
        FlashMessage.sharedInstance.showNotification(inViewController: visibleViewController, title: FlashMessageTitles.downloadingTeamsFailed, canBeDismissedByUser: true)
    }

    func viewModel(_ viewModel: BaseCollectionViewViewModel, didLoadItemsAtIndexPaths indexPaths: [IndexPath]) {
        profileInfoView.teamsCollectionView.insertItems(at: indexPaths)
    }

    func viewModel(_ viewModel: BaseCollectionViewViewModel, didLoadShotsForItemAtIndexPath indexPath: IndexPath) {
        profileInfoView.teamMembersTableView.reloadRows(at: [indexPath], with: .none)
    }

}

// MARK: CarouselCellDelegate

extension ProfileInfoViewController: CarouselCellDelegate {
    
    func carouselCell(_ carouselCell: CarouselCell, didTap item: Int, for shot: ShotType) {
        
        var user: UserType? = nil
        var controller: ShotDetailsViewController
        
        if viewModel.user.accountType == .Team {
            guard let carouselCellIndex = profileInfoView.teamMembersTableView.indexPath(for: carouselCell), let shots = viewModel.shots(forIndex: carouselCellIndex.row) else { return }
            currentContainer = shots
            user = viewModel.member(forIndex: carouselCellIndex.item)
        } else {
            currentContainer = viewModel.userLikedShots
        }
        
        if let user = user {
            let shotWithUser = Shot(identifier: shot.identifier, title: shot.title, attributedDescription: shot.attributedDescription, user: user, shotImage: shot.shotImage, createdAt: shot.createdAt, animated: shot.animated, likesCount: shot.likesCount, viewsCount: shot.viewsCount, commentsCount: shot.commentsCount, bucketsCount: shot.bucketsCount, team: shot.team, attachmentsCount: shot.attachmentsCount, htmlUrl: shot.htmlUrl)
            
            controller = ShotDetailsViewController(shot: shotWithUser)
        } else {
            controller = ShotDetailsViewController(shot: shot)
        }

        controller.shotIndex = item
        presentShotDetails(with: controller)
    }
}

extension ProfileInfoViewController {
    func presentShotDetails(with controller: ShotDetailsViewController) {
        
        controller.customizeFor3DTouch(false)
        
        let shotDetailsPageDataSource = ShotDetailsPageViewControllerDataSource(shots: currentContainer, initialViewController: controller)
        let pageViewController = ShotDetailsPageViewController(shotDetailsPageDataSource: shotDetailsPageDataSource)
        
        modalTransitionAnimator = CustomTransitions.pullDownToCloseTransitionForModalViewController(pageViewController)
        modalTransitionAnimator?.behindViewScale = 1
        
        pageViewController.transitioningDelegate = modalTransitionAnimator
        pageViewController.modalPresentationStyle = .custom
        
        present(pageViewController, animated: true, completion: nil)
    }
}
