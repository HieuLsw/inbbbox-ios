//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import Dobby

@testable import Inbbbox

class ViewControllerPresenterMock: ViewControllerPresenter {

    let presentViewControllerStub = Stub<(UIViewController, Bool, (() -> Void)?), Void>()
    let dismissViewControllerAnimatedStub = Stub<(Bool, (() -> Void)?), Void>()

//    MARK: - ViewControllerPresenter

    func presentViewController(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        try! presentViewControllerStub.invoke(viewControllerToPresent, animated, completion)
    }

    func dismissViewControllerAnimated(_ animated: Bool, completion: (() -> Void)?) {
        try! dismissViewControllerAnimatedStub.invoke(animated, completion)
    }
}
