//
//  ShotDetailsPageViewControllerDataSource.swift
//  Inbbbox
//
//  Created by Robert Abramczyk on 26/10/2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

class ShotDetailsPageViewControllerDataSource: NSObject, UIPageViewControllerDataSource {
    
    // MARK: Properties
    
    weak var delegate: ShotDetailsPageDelegate?
    
    var shots = [ShotType]()
    fileprivate var shotDetailsViewControllersDictionary = [Int:ShotDetailsViewController]()
    var initialViewController: ShotDetailsViewController? {
        return shotDetailsViewControllersDictionary.values.first
    }
    
    // MARK: Life cycle
    
    init(shots: [ShotType], initialViewController: ShotDetailsViewController) {
        super.init()
        
        self.shots = shots
        initialViewController.willDismissDetailsCompletionHandler = willDismissWithIndex
        shotDetailsViewControllersDictionary[initialViewController.shotIndex] = initialViewController
    }
    
    // MARK: Private
    
    fileprivate func getShotDetailsViewController(atIndexPath indexPath: IndexPath) -> UIViewController {
        
        if let controller = shotDetailsViewControllersDictionary[(indexPath as NSIndexPath).row] { return controller }
        
        let shot = shots[(indexPath as NSIndexPath).row]
        let shotDetailsViewController = ShotDetailsViewController(shot: shot)
        shotDetailsViewController.shotIndex = (indexPath as NSIndexPath).row
        shotDetailsViewControllersDictionary[(indexPath as NSIndexPath).row] = shotDetailsViewController
        shotDetailsViewController.customizeFor3DTouch(false)
        shotDetailsViewController.willDismissDetailsCompletionHandler = willDismissWithIndex
        
        return shotDetailsViewController
    }
    
    fileprivate func willDismissWithIndex(_ index: Int) {
        delegate?.shotDetailsDismissed(atIndex: index)
    }
    
    // MARK: UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentController = viewController as? ShotDetailsViewController,
            currentController.shotIndex > 0 {
            return getShotDetailsViewController(atIndexPath: IndexPath(item: currentController.shotIndex - 1, section: 0)) as? ShotDetailsViewController
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentController = viewController as? ShotDetailsViewController,
            currentController.shotIndex < shots.count - 1 {
            return getShotDetailsViewController(atIndexPath: IndexPath(item: currentController.shotIndex + 1, section: 0)) 
        }
        return nil
    }
}

protocol ShotDetailsPageDelegate: class {
    
    func shotDetailsDismissed(atIndex index: Int)
}
