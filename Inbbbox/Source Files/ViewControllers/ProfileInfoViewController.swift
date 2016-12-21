//
//  ProfileInfoViewController.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ProfileInfoViewController: UIViewController, UICollectionViewDelegate {

    let viewModel: ProfileInfoViewModel

    var profileInfoView: ProfileInfoView! {
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

        profileInfoView.teamsCollectionView.delegate = self
        profileInfoView.teamsCollectionView.dataSource = self
        profileInfoView.teamsCollectionView.register(TeamCollectionViewCell.self, forCellWithReuseIdentifier: TeamCollectionViewCell.identifier)
        profileInfoView.teamsCollectionView.isScrollEnabled = false

        profileInfoView.shotsAmountView.valueLabel.text = viewModel.shotsCount
        profileInfoView.followersAmountView.valueLabel.text = viewModel.followersCount
        profileInfoView.followingAmountView.valueLabel.text = viewModel.followingsCount

        profileInfoView.teamsCollectionView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileInfoView.teamsCollectionViewFlowLayout.itemSize = CGSize(width: profileInfoView.frame.size.width / 2, height: 65)
        profileInfoView.teamsCollectionViewFlowLayout.minimumInteritemSpacing = 0
        profileInfoView.teamsCollectionViewFlowLayout.minimumLineSpacing = 0
    }

    override func loadView() {
        view = ProfileInfoView(frame: .zero)
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

}
