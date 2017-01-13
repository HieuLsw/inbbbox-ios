//
//  ShotsOnboardingStateHandlerSpec.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class ShotsOnboardingStateHandlerSpec: QuickSpec {

   /* override func spec() {
        var sut: ShotsOnboardingStateHandler!
        var collectionView: ShotsCollectionViewController!
        
        beforeEach {
            sut = ShotsOnboardingStateHandler()
            collectionView = ShotsCollectionViewController(frame: CGRect(x: 0, y: 0, width: 320, height: 568), collectionViewLayout: sut.collectionViewLayout)
        }
        
        afterEach {
            sut = nil
            collectionView = nil
        }
        
        describe("when initialized") {
            
            context("should have initial values") {
                
                it("number of sections and items should be accurate") {
                    expect(sut.collectionView(collectionView, numberOfItemsInSection: 0)).to(equal(5))
                }
                
                it("onboarding steps have proper actions") {
                    let actions: [ShotCollectionViewCell.Action] = [.like, .bucket, .comment, .follow, .doNothing]
                    for (index, element) in sut.onboardingSteps.enumerated() {
                        expect(element.action).to(equal(actions[index]))
                    }
                }
                
                it("validate states") {
                    expect(sut.state).to(equal(ShotsCollectionViewController.State.onboarding))
                    expect(sut.nextState).to(equal(ShotsCollectionViewController.State.normal))
                }
                
            }
            
            context("cells handling") {
                //expect(collectionView.indexPathsForVisibleItems).to(haveCount(1))
            }
        }
    }*/

}
