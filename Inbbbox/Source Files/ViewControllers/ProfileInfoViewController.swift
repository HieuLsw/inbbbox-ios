//
//  ProfileInfoViewController.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

final class ProfileInfoViewController: UIViewController, UICollectionViewDelegate {

    fileprivate let viewModel: ProfileInfoViewModel

    private var profileInfoView: ProfileInfoView! {
        return view as? ProfileInfoView
    }

    init(user: UserType) {
        self.viewModel = ProfileInfoViewModel(user: user)
        super.init(nibName: nil, bundle: nil)
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
        setupTeamsCollectionView()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileInfoView.teamsCollectionViewFlowLayout.itemSize = CGSize(width: profileInfoView.frame.size.width / 2, height: 65)
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

    private func setupUI() {
        profileInfoView.shotsAmountView.valueLabel.text = viewModel.shotsCount
        profileInfoView.followersAmountView.valueLabel.text = viewModel.followersCount
        profileInfoView.followingAmountView.valueLabel.text = viewModel.followingsCount
        profileInfoView.locationView.locationLabel.text = viewModel.location
        profileInfoView.bioLabel.text = viewModel.bio
        profileInfoView.locationView.isHidden = viewModel.shouldHideLocation
    }

}

extension ProfileInfoViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamCollectionViewCell.identifier, for: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: TeamsCollectionHeaderView.identifier, for: indexPath)
        return header
    }


}
