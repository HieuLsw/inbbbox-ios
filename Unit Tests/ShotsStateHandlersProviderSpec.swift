//
//  ShotsStateHandlersProviderSpec.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class ShotsStateHandlersProviderSpec: QuickSpec {
    
    override func spec() {
        
        var sut: ShotsStateHandlersProvider!
        
        beforeEach {
            sut = ShotsStateHandlersProvider()
        }
        
        afterEach {
            sut = nil
        }
        
        describe("handler for state") {
            context("should return proper handler for state") {
                it("types of values should be proper") {
                    expect(sut.shotsStateHandlerForState(.initialAnimations) is ShotsInitialAnimationsStateHandler).to(beTruthy())
                    expect(sut.shotsStateHandlerForState(.onboarding) is ShotsOnboardingStateHandler).to(beTruthy())
                    expect(sut.shotsStateHandlerForState(.normal) is ShotsNormalStateHandler).to(beTruthy())
                }
                
            }
        }
        
    }
}
