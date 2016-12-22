//
//  Support3DTouch.swift
//  Inbbbox
//
//  Created by Blazej Wdowikowski on 12/15/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import PeekPop

protocol Support3DTouch: class {
    var didCheckedSupport3DForOlderDevices: Bool { get set }
    var peekPop: PeekPop? { get set }
}

extension Support3DTouch {
    
    func addSupport3DForOlderDevicesIfNeeded(with delegate: PeekPopPreviewingDelegate, viewController: UIViewController , sourceView view: UIView) {
        guard viewController.traitCollection.forceTouchCapability == .unknown, !didCheckedSupport3DForOlderDevices  else { return }
        addSupport3DForOlderDevices(with: delegate, viewController: viewController, sourceView: view)
        didCheckedSupport3DForOlderDevices = true
    }
    
    private func addSupport3DForOlderDevices(with delegate: PeekPopPreviewingDelegate, viewController: UIViewController , sourceView view: UIView) {
        peekPop = PeekPop(viewController: viewController)
        _ = peekPop?.registerForPreviewingWithDelegate(delegate, sourceView: view)
    }
}
