//
//  BaseCollectionViewViewModelSpec.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 25.05.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class BaseCollectionViewViewModelSpec: QuickSpec {

    override func spec() {

        /// Test if `notifyDelegateAboutFailure` method from
        /// BaseCollectionViewViewModel extension is implemented correctly.

        describe("When downloading items for next page") {

            let sut = ViewModelMock()
            let fakeDelegate = ViewModelDelegate()
            sut.delegate = fakeDelegate

            beforeEach {
                fakeDelegate.didCallDelegate = false
            }

            it("should be able to call delegate for PageableProviderError errors") {
                sut.mockDownloadItemsFailure(PageableProviderError.behaviourUndefined)

                expect(fakeDelegate.didCallDelegate).toEventually(beTrue())
            }

            it("should not be able to call delegate if error = DidReachLastPage") {
                sut.mockDownloadItemsFailure(PageableProviderError.didReachLastPage)

                expect(fakeDelegate.didCallDelegate).toEventually(beFalse())
            }

            it("should be able to call delegate for other errors") {
                sut.mockDownloadItemsFailure(APIRateLimitKeeperError.didExceedRateLimitPerDay(1))

                expect(fakeDelegate.didCallDelegate).toEventually(beTrue())
            }
        }
    }
}

class ViewModelDelegate: BaseCollectionViewViewModelDelegate {
    var didCallDelegate = false

    func viewModelDidFailToLoadItems(_ error: Error) {
        self.didCallDelegate = true
    }

    func viewModelDidLoadInitialItems() {
        // Just conforming to protocol
    }

    func viewModelDidFailToLoadInitialItems(_ error: Error) {
        // Just conforming to protocol
    }

    func viewModel(_ viewModel: BaseCollectionViewViewModel, didLoadItemsAtIndexPaths indexPaths: [IndexPath]) {
        // Just conforming to protocol
    }

    func viewModel(_ viewModel: BaseCollectionViewViewModel, didLoadShotsForItemAtIndexPath indexPath: IndexPath) {
        // Just conforming to protocol
    }
}

/// It does not matter from which model we subclass
/// until it adopts SimpleShotsViewModel protocol.

private class ViewModelMock: LikesViewModel {

    func mockDownloadItemsFailure(_ error: Error) {
        notifyDelegateAboutFailure(error)
    }
}

