//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ShotsStateHandlersProvider {

    func shotsStateHandlerForState(_ state: ShotsCollectionViewController.State) -> ShotsStateHandler {
        switch state {
        case .onboarding:
            return ShotsOnboardingStateHandler()
        case .initialAnimations:
            return ShotsInitialAnimationsStateHandler()
        case .normal:
            return ShotsNormalStateHandler()
        }
    }
}
