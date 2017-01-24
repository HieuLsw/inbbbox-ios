//
//  ProfilePageViewController.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ProfilePageViewController: UIPageViewController {

    fileprivate(set) var internalDataSource: ProfilePageViewControllerDataSource?

    init(_ dataSource: ProfilePageViewControllerDataSource) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        internalDataSource = dataSource
        self.dataSource = internalDataSource
    }

    @available(*, unavailable, message: "Use init(_:)")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setViewControllers([internalDataSource?.initialViewController ?? UIViewController()], direction: .forward, animated: true, completion: nil)
    }

    func selectPage(at index: Int, scrollDirection: UIPageViewControllerNavigationDirection) {
        guard let internalDataSource = internalDataSource else { return }
        
        setViewControllers([internalDataSource.viewControllers[index]], direction: scrollDirection, animated: true, completion: nil)
    }
}
