//
//  ScrollViewAutoScroller.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 09/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ScrollViewAutoScroller {

    /// Defines how many scroll action should be suppressed by ScrollViewAutoScroller
    var autoScrollInvocationSuppressCount = 1

    /// scroll view to use by ScrollViewAutoScroller
    weak var scrollView: UIScrollView?

    fileprivate var autoScrollInvocationSuppressCounter = 0
    fileprivate var shouldAllowScrollAction: Bool {
        return autoScrollInvocationSuppressCounter >= autoScrollInvocationSuppressCount
    }

    /**
     Scrolls owned UIScrollView instance (if any) to bottom.

     - Warning: scroll action will be perfomed only if invocation counter will be greater or equal to supress counter.

     - parameter animated: Indicates whether scroll should be animated or not.
     */
    func scrollToBottomAnimated(_ animated: Bool) {

        guard let scrollView = self.scrollView, shouldAllowScrollAction else {
            autoScrollInvocationSuppressCounter += 1
            return
        }

        DispatchQueue.main.async {
            let rect = CGRect(x: 0, y: scrollView.contentSize.height - 1, width: 1, height: 1)
            scrollView.scrollRectToVisible(rect, animated: animated)
        }
    }
}
