//
//  ProfileInfoViewController.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ProfileInfoViewController: UIViewController {

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
        profileInfoView.shotsAmountView.valueLabel.text = viewModel.shotsCount
        profileInfoView.followersAmountView.valueLabel.text = viewModel.followersCount
        profileInfoView.followingAmountView.valueLabel.text = viewModel.followingsCount
    }

    override func loadView() {
        view = ProfileInfoView(frame: .zero)
    }


}
