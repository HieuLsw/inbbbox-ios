//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

protocol ViewControllerPresenter {

    func presentViewController(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?)

    func dismissViewControllerAnimated(_ animated: Bool, completion: (() -> Void)?)
}
