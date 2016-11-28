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
    let containsLikesData: Bool?
    private var shotDetailsViewControllersDictionary = [Int:ShotDetailsViewController]()
    var initialViewController: ShotDetailsViewController? {
        return shotDetailsViewControllersDictionary.values.first
    }
    
    // MARK: Life cycle
    
    init(shots: [ShotType], initialViewController: ShotDetailsViewController, likesData: Bool? = nil) {
        self.containsLikesData = likesData
        super.init()
        
        self.shots = shots
        initialViewController.willDismissDetailsCompletionHandler = willDismissWithIndex
        shotDetailsViewControllersDictionary[initialViewController.shotIndex] = initialViewController
    }
    
    // MARK: Private
    
    private func getShotDetailsViewController(atIndexPath indexPath: NSIndexPath) -> UIViewController {
        
        if let controller = shotDetailsViewControllersDictionary[indexPath.row] { return controller }
        
        let shot = shots[indexPath.row]
        let shotDetailsViewController = ShotDetailsViewController(shot: shot, isLiked: containsLikesData)
        shotDetailsViewController.shotIndex = indexPath.row
        shotDetailsViewControllersDictionary[indexPath.row] = shotDetailsViewController
        shotDetailsViewController.customizeFor3DTouch(false)
        shotDetailsViewController.willDismissDetailsCompletionHandler = willDismissWithIndex
        
        return shotDetailsViewController
    }
    
    private func willDismissWithIndex(index: Int) {
        delegate?.shotDetailsDismissed(atIndex: index)
    }
    
    // MARK: UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if let currentController = viewController as? ShotDetailsViewController where
            currentController.shotIndex > 0 {
            return getShotDetailsViewController(atIndexPath: NSIndexPath(forItem: currentController.shotIndex - 1, inSection: 0))
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if let currentController = viewController as? ShotDetailsViewController where
            currentController.shotIndex < shots.count - 1 {
            return getShotDetailsViewController(atIndexPath: NSIndexPath(forItem: currentController.shotIndex + 1, inSection: 0)) 
        }
        return nil
    }
}

protocol ShotDetailsPageDelegate: class {
    
    func shotDetailsDismissed(atIndex index: Int)
}
