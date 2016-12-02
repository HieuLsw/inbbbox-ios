//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class DefaultViewControllerPresenter: ViewControllerPresenter {

    fileprivate(set) weak var presentingViewController: UIViewController?

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }

//    MARK: - ViewControllerPresenter

    func presentViewController(_ viewController: UIViewController,
                                     animated: Bool,
                                   completion: (() -> Void)?) {
        presentingViewController?.present(viewController,
                                              animated: animated,
                                            completion: completion)
    }

    func dismissViewControllerAnimated(_ animated: Bool, completion: (() -> Void)?) {
        presentingViewController?.dismiss(animated: animated, completion: completion)
    }
}
