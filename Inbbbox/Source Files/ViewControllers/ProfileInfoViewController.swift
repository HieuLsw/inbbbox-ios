//
//  ProfileInfoViewController.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ProfileInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func loadView() {
        view = ProfileInfoView(frame: .zero)
        view.backgroundColor = .white
    }


}
