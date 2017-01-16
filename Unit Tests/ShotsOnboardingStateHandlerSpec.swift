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

    override func spec() {
        var sut: ShotsOnboardingStateHandler!
        var collectionViewController: ShotsCollectionViewController!
        
        beforeEach {
            sut = ShotsOnboardingStateHandler()
            collectionViewController = ShotsCollectionViewController()
        }
        
        afterEach {
            sut = nil
            collectionViewController = nil
        }
        
        describe("when initialized") {
            
            context("should have initial values") {
                
                it("number of sections and items should be accurate") {
                    expect(sut.collectionView(collectionViewController.collectionView!, numberOfItemsInSection: 0)).to(equal(5))
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
                
                it("swiping cells with proper action should move to next steps") {
                    let collectionView = collectionViewController.collectionView!
                    let likeCell = sut.collectionView(collectionView, cellForItemAt: IndexPath(item: 0, section: 0)) as! ShotCollectionViewCell
                    let bucketCell = sut.collectionView(collectionView, cellForItemAt: IndexPath(item: 1, section: 0)) as! ShotCollectionViewCell
                    let commentCell = sut.collectionView(collectionView, cellForItemAt: IndexPath(item: 2, section: 0)) as! ShotCollectionViewCell
                    let followCell = sut.collectionView(collectionView, cellForItemAt: IndexPath(item: 3, section: 0)) as! ShotCollectionViewCell

                    likeCell.swipeCompletion!(.like)
                    expect(collectionView.contentOffset.y).toEventually(beCloseTo(667))
                    bucketCell.swipeCompletion!(.bucket)
                    expect(collectionView.contentOffset.y).toEventually(beCloseTo(1334))
                    commentCell.swipeCompletion!(.comment)
                    expect(collectionView.contentOffset.y).toEventually(beCloseTo(2001))
                    followCell.swipeCompletion!(.follow)
                    expect(collectionView.contentOffset.y).toEventually(beCloseTo(2668))
                }
                
                it("only proper action should move to next step") {
                    let collectionView = collectionViewController.collectionView!
                    let likeCell = sut.collectionView(collectionView, cellForItemAt: IndexPath(item: 0, section: 0)) as! ShotCollectionViewCell
                    expect(collectionView.contentOffset.y).to(beCloseTo(0))
                    likeCell.swipeCompletion!(.bucket)
                    likeCell.swipeCompletion!(.comment)
                    likeCell.swipeCompletion!(.follow)
                    expect(collectionView.contentOffset.y).to(beCloseTo(0))
                }
            }
        }
    }
}
