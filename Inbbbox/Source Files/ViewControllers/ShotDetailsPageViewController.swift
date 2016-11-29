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
    fileprivate var didSetConstraints = false
    
    // MARK: Life cycle
    
    @available(*, unavailable, message: "Use init() method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(shotDetailsPageDataSource: ShotDetailsPageViewControllerDataSource) {
        pageDataSource = shotDetailsPageDataSource
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
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

// MARK: ModalByDraggingClosable

extension ShotDetailsPageViewController: ModalByDraggingClosable {
    var scrollViewToObserve: UIScrollView {
        for v in view.subviews{
            if v.isKind(of: UIScrollView.self){
                return v as! UIScrollView
            }
        }
        return UIScrollView()
    }
}
