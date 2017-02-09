//
//  ProfileInfoViewController.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Async
import Haneke
import PromiseKit
import UIKit

final class ProfileInfoViewController: UIViewController, ContainingScrollableView {
    
    fileprivate let viewModel: ProfileInfoViewModel

    fileprivate var currentColorMode = ColorModeProvider.current()

    fileprivate var profileInfoView: ProfileInfoView! {
        return view as? ProfileInfoView
    }
    
    var scrollableView: UIScrollView {
        return profileInfoView.scrollView
    }
    
    var scrollContentOffset: (() -> CGPoint)?

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
        setupUI()
        setupTeamsCollectionView()
        setupTeamMembersTableView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileInfoView.teamsCollectionViewFlowLayout.itemSize = CGSize(width: profileInfoView.frame.size.width / 2, height: 65)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewModel.itemsCount == 0 && viewModel.teamsCount == 0 && viewModel.teamMembersCount == 0 {
            profileInfoView.scrollView.updateInsets(bottom: profileInfoView.scrollView.frame.height)
        }
        
        if let offset = scrollContentOffset?() {
            profileInfoView.scrollView.contentOffset = offset
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.downloadInitialItems()
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

    private func setupTeamMembersTableView() {
        profileInfoView.teamMembersTableView.delegate = self
        profileInfoView.teamMembersTableView.dataSource = self
        profileInfoView.teamMembersTableView.register(CarouselCell.self, forCellReuseIdentifier: CarouselCell.identifier)
        profileInfoView.teamMembersTableView.rowHeight = UITableViewAutomaticDimension
        profileInfoView.teamMembersTableView.estimatedRowHeight = 165
        profileInfoView.teamMembersTableView.separatorStyle = .none
        profileInfoView.teamMembersTableView.isScrollEnabled = false
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

}

extension ProfileInfoViewController: UITableViewDelegate {

}

extension ProfileInfoViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.teamMembersCount
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

        let teamMember = viewModel.member(forIndex: indexPath.row)
        cell.titleLabel.text = teamMember.name
        cell.backgroundLabel.text = teamMember.name
        cell.shots = viewModel.shots(forIndex: indexPath.row)

        return cell
    }
    
    func adjustScrollView() {
        if viewModel.itemsCount == 0 && viewModel.teamsCount == 0 && viewModel.teamMembersCount == 0 {
            profileInfoView.scrollView.updateInsets(bottom: profileInfoView.scrollView.frame.height)
        } else {
            if profileInfoView.scrollView.contentSize.height < profileInfoView.scrollView.frame.height {
                profileInfoView.scrollView.updateInsets(bottom: profileInfoView.scrollView.frame.height - profileInfoView.scrollView.contentSize.height)
            } else {
                profileInfoView.scrollView.updateInsets(bottom: 0)
            }
        }
        guard let offset = self.scrollContentOffset?() else { return }
        profileInfoView.scrollView.contentOffset = offset
    }
}

extension ProfileInfoViewController: BaseCollectionViewViewModelDelegate {

    func viewModelDidLoadInitialItems() {
        profileInfoView.teamsCollectionView.reloadData()
        profileInfoView.teamMembersTableView.reloadData()
        setupUI()
        profileInfoView.updateLayout()
        
        Async.main(after: 0.01) {
            self.adjustScrollView()
        }
    }

    func viewModelDidFailToLoadInitialItems(_ error: Error) {
        profileInfoView.teamsCollectionView.reloadData()

        Async.main(after: 0.01) {
            if let offset = self.scrollContentOffset?() {
                self.profileInfoView.scrollView.contentOffset = offset
            }
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
