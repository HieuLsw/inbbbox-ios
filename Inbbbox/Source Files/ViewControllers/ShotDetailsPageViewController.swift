//
//  ShotDetailsPageViewController.swift
//  Inbbbox
//
//  Created by Robert Abramczyk on 25/10/2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import ZFDragableModalTransition

class ShotDetailsPageViewController: UIPageViewController {
    fileprivate let blurView = UIVisualEffectView(effect: UIBlurEffect(style: ColorModeProvider.current().visualEffectBlurType))
    fileprivate var modalTransitionAnimator: ZFModalTransitionAnimator?
    var pageDataSource: ShotDetailsPageViewControllerDataSource

    var didUpdateInternalViewController: ((ShotDetailsViewController) -> Void)?
    fileprivate var didSetConstraints = false
    
    // MARK: Life cycle
    
    @available(*, unavailable, message: "Use init() method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(shotDetailsPageDataSource: ShotDetailsPageViewControllerDataSource) {
        pageDataSource = shotDetailsPageDataSource
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

        delegate = self
    }
}

// MARK: UIViewController

extension ShotDetailsPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = pageDataSource
        
        if let controller = pageDataSource.initialViewController {
            setViewControllers([controller],
                                   direction: .forward,
                                   animated: true,
                                   completion: nil)
        }
        
        let currentColorMode = ColorModeProvider.current()
        if DeviceInfo.shouldDowngrade() {
            view.backgroundColor = currentColorMode.tableViewBackground
        } else {
            view.backgroundColor = currentColorMode.tableViewBlurColor
            blurView.configureForAutoLayout()
            view.addSubview(blurView)
            view.sendSubview(toBack: blurView)
        }
        
        updateConstraints()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ColorModeProvider.current().preferredStatusBarStyle
    }
    
    func updateConstraints() {
        
        if !didSetConstraints {
            didSetConstraints = true
            
            if !DeviceInfo.shouldDowngrade() {
                blurView.autoPinEdgesToSuperviewEdges()
            }
        }
    }
}

// MARK: UIPageViewControllerDelegate

extension ShotDetailsPageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let viewController = viewControllers?.last as? ShotDetailsViewController else { return }

        didUpdateInternalViewController?(viewController)
    }
}

// MARK: ModalByDraggingClosable

extension ShotDetailsPageViewController: ModalByDraggingClosable {
    var scrollViewToObserve: UIScrollView {
        guard let viewController = viewControllers?.last as? ShotDetailsViewController else { return UIScrollView() }

        return viewController.scrollViewToObserve
    }
}
