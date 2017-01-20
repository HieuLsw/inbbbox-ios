//
//  ProfilePageViewController.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ProfilePageViewController: UIPageViewController {

    private var internalDataSource: UIPageViewControllerDataSource?

    init(_ dataSource: UIPageViewControllerDataSource) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        internalDataSource = dataSource
        self.dataSource = internalDataSource
    }

    @available(*, unavailable, message: "Use init(_:)")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        let vc = UIViewController()
        vc.view.backgroundColor = .blue
        setViewControllers([vc], direction: .forward, animated: true, completion: nil)
    }
}
