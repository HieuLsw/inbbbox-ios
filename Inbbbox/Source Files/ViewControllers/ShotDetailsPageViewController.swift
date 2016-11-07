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
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: ColorModeProvider.current() is DayMode ? .Light : .Dark))
    private var modalTransitionAnimator: ZFModalTransitionAnimator?
    var pageDataSource: ShotDetailsPageViewControllerDataSource
    private var didSetConstraints = false
    
    // MARK: Life cycle
    
    @available(*, unavailable, message = "Use init() method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(shotDetailsPageDataSource: ShotDetailsPageViewControllerDataSource) {
        pageDataSource = shotDetailsPageDataSource
        
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    }
}

// MARK: UIViewController

extension ShotDetailsPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = pageDataSource
        
        if let controller = pageDataSource.initialViewController {
            setViewControllers([controller],
                                   direction: .Forward,
                                   animated: true,
                                   completion: nil)
        }
        
        if DeviceInfo.shouldDowngrade() {
            view.backgroundColor = .backgroundGrayColor()
        } else {
            view.backgroundColor = .clearColor()
            blurView.configureForAutoLayout()
            view.addSubview(blurView)
            view.sendSubviewToBack(blurView)
        }
        
        updateConstraints()
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

// MARK: ModalByDraggingClosable

extension ShotDetailsPageViewController: ModalByDraggingClosable {
    var scrollViewToObserve: UIScrollView {
        for v in view.subviews{
            if v.isKindOfClass(UIScrollView){
                return v as! UIScrollView
            }
        }
        return UIScrollView()
    }
}
