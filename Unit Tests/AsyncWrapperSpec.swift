//
//  AsyncWrapperSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 31/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class AsyncWrapperSpec: QuickSpec {
    override func spec() {

        var sut: AsyncWrapper!

        beforeEach {
            sut = AsyncWrapper()
        }

        afterEach {
            sut = nil
        }

        describe("when executing closure after delay") {

            var didExecuteClosure = false
            var isMainThread = false

            beforeEach {

                waitUntil { done in
                    sut.main(after: 0.1) {
                        didExecuteClosure = true
                        isMainThread = Thread.isMainThread
                        done()
                    }
                }
            }

            it("closure should be executed") {
                expect(didExecuteClosure).to(beTruthy())
            }

            it("closure should be executed on main thread") {
                expect(isMainThread).to(beTruthy())
            }
        }
    }
}
