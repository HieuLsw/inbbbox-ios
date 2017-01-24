//
//  ProfilePageViewControllerDataSource.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ProfilePageViewControllerDataSource: NSObject, UIPageViewControllerDataSource {

    let viewControllers: [UIViewController]

    var initialViewController: UIViewController? {
        return viewControllers.first
    }

    init(viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
        super.init()
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let index = viewControllers.index(of: viewController) else { return nil }

        return viewControllers.startIndex == index ? nil : viewControllers[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let index = viewControllers.index(of: viewController) else { return nil }

        return viewControllers.endIndex - 1 == index ? nil : viewControllers[index + 1]
    }

}
