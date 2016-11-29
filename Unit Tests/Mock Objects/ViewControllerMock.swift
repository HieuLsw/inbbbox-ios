//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import Dobby

@testable import Inbbbox

class ViewControllerMock: UIViewController {

    let presentViewControllerStub = Stub<(UIViewController, Bool, (() -> Void)?), Void>()
    let dismissViewControllerAnimatedStub = Stub<(Bool, (() -> Void)?), Void>()

//    MARK: - UIViewControlelr

    override func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        try! presentViewControllerStub.invoke(viewControllerToPresent, animated, completion)
    }

    override func dismiss(animated: Bool, completion: (() -> Void)?) {
        try! dismissViewControllerAnimatedStub.invoke(animated, completion)
    }
}
