//
//  ProfileInfoViewController.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Haneke
import PromiseKit
import UIKit

final class ProfileInfoViewController: UIViewController, UICollectionViewDelegate {

    fileprivate let viewModel: ProfileInfoViewModel

    fileprivate var profileInfoView: ProfileInfoView! {
        return view as? ProfileInfoView
    }

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
        self.setupUI()
        setupTeamsCollectionView()
        viewModel.refreshUserData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileInfoView.teamsCollectionViewFlowLayout.itemSize = CGSize(width: profileInfoView.frame.size.width / 2, height: 65)
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

    fileprivate func setupUI() {
        profileInfoView.shotsAmountView.valueLabel.text = viewModel.shotsCount
        profileInfoView.followersAmountView.valueLabel.text = viewModel.followersCount
        profileInfoView.followingAmountView.valueLabel.text = viewModel.followingsCount
        profileInfoView.locationView.locationLabel.text = viewModel.location
        profileInfoView.bioLabel.text = viewModel.bio
        profileInfoView.locationView.isHidden = viewModel.shouldHideLocation
        profileInfoView.teamsCollectionView.isHidden = viewModel.shouldHideTeams
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

extension ProfileInfoViewController: BaseCollectionViewViewModelDelegate {

    func viewModelDidLoadInitialItems() {
        profileInfoView.teamsCollectionView.reloadData()
        setupUI()
    }

    func viewModelDidFailToLoadInitialItems(_ error: Error) {
        profileInfoView.teamsCollectionView.reloadData()

        if viewModel.isTeamsEmpty {
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.tryAgain, canBeDismissedByUser: true)
        }
    }

    func viewModelDidFailToLoadItems(_ error: Error) {
        FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.downloadingTeamsFailed, canBeDismissedByUser: true)
    }

    func viewModel(_ viewModel: BaseCollectionViewViewModel, didLoadItemsAtIndexPaths indexPaths: [IndexPath]) {
        profileInfoView.teamsCollectionView.insertItems(at: indexPaths)
    }

    func viewModel(_ viewModel: BaseCollectionViewViewModel, didLoadShotsForItemAtIndexPath indexPath: IndexPath) {
        profileInfoView.teamsCollectionView.reloadItems(at: [indexPath])
    }

}
