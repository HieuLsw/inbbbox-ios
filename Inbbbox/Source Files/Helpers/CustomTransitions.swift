//
//  CustomTransitions.swift
//  Inbbbox
//
//  Created by Peter Bruz on 07/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import ZFDragableModalTransition

protocol ModalByDraggingClosable {
    var scrollViewToObserve: UIScrollView { get }
}

class CustomTransitions {

    class func pullDownToCloseTransitionForModalViewController<T: UIViewController
            where T: ModalByDraggingClosable>(modalViewController: T) -> ZFModalTransitionAnimator {

        let modalTransitionAnimator =
                ZFModalTransitionAnimator(modalViewController: modalViewController)
        modalTransitionAnimator.dragable = true
        modalTransitionAnimator.direction = ZFModalTransitonDirection.Bottom
        modalTransitionAnimator.setContentScrollView(modalViewController.scrollViewToObserve)
        modalTransitionAnimator.bounces = false
        modalTransitionAnimator.transitionDuration = 0.4

        return modalTransitionAnimator
    }
}
