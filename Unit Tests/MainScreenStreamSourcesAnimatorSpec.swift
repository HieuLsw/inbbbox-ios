//
//  MainScreenStreamSourcesAnimatorSpec.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 02.11.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import Dobby

@testable import Inbbbox

class MainScreenStreamSourcesAnimatorSpec: QuickSpec {

    override func spec() {
        var sut: MainScreenStreamSourcesAnimator?
        var view: ShotsCollectionBackgroundView?
        
        beforeEach {
            let backgroundView = ShotsCollectionBackgroundView()
            backgroundView.frame = UIScreen.main.bounds
            backgroundView.layoutSubviews()
            sut = MainScreenStreamSourcesAnimator(view: backgroundView, animationDuration: 0.01)
            view = backgroundView
            Settings.StreamSource.Debuts = true
            Settings.StreamSource.Following = true
        }
        
        afterEach {
            sut = nil
            view = nil
            Settings.StreamSource.Debuts = false
            Settings.StreamSource.Following = false
        }
        
        it("At start stream sources should be hidden") {
            expect(sut?.areStreamSourcesShown).to(beFalsy())
        }
        
        it("At start animation should not be running") {
            expect(sut?.isAnimationInProgress).to(beFalsy())
        }
        
        it("Show function should run without animation") {
            sut?.showStreamSources()
            expect(view?.showingYouLabel.alpha).to(equal(1))
            expect(view?.showingYouVerticalConstraint?.constant).to(equal(ShotsCollectionBackgroundViewSpacing.showingYouDefaultVerticalSpacing))
            expect(view?.logoImageView.alpha).to(equal(0))
            expect(view?.logoVerticalConstraint?.constant).to(equal(ShotsCollectionBackgroundViewSpacing.logoAnimationVerticalInset))
            expect(sut?.areStreamSourcesShown).to(beTruthy())
        }
        
        it("Hide function should run without animation") {
            sut?.hideStreamSources()
            expect(view?.showingYouLabel.alpha).to(equal(0))
            expect(view?.showingYouVerticalConstraint?.constant).to(equal(ShotsCollectionBackgroundViewSpacing.showingYouHiddenVerticalSpacing))
            expect(view?.logoImageView.alpha).to(equal(1))
            expect(view?.logoVerticalConstraint?.constant).to(equal(ShotsCollectionBackgroundViewSpacing.logoDefaultVerticalInset))
            expect(sut?.areStreamSourcesShown).to(beFalsy())
            for item in view!.availableItems() {
                expect(item.label.alpha).to(equal(0))
            }
        }
        
        
        it("Fade in animation should show views in proper places") {
            sut?.startFadeInAnimation()
            expect(view?.showingYouLabel.alpha).toEventually(equal(1))
            expect(view?.showingYouVerticalConstraint?.constant).toEventually(equal(ShotsCollectionBackgroundViewSpacing.showingYouDefaultVerticalSpacing))
            expect(view?.logoImageView.alpha).toEventually(equal(0))
            expect(view?.logoVerticalConstraint?.constant).toEventually(equal(ShotsCollectionBackgroundViewSpacing.logoAnimationVerticalInset))
            expect(sut?.areStreamSourcesShown).toEventually(beTruthy())
            for item in view!.availableItems() {
                expect(item.label.alpha).toEventually(equal(1))
            }
        }
        
        it("Fade out animation should show views in proper places") {
            sut?.showStreamSources()
            sut?.startFadeOutAnimation()
            expect(view?.showingYouLabel.alpha).toEventually(equal(0))
            expect(view?.showingYouVerticalConstraint?.constant).toEventually(equal(ShotsCollectionBackgroundViewSpacing.showingYouHiddenVerticalSpacing))
            expect(view?.logoImageView.alpha).toEventually(equal(1))
            expect(view?.logoVerticalConstraint?.constant).toEventually(equal(ShotsCollectionBackgroundViewSpacing.logoDefaultVerticalInset))
            expect(sut?.areStreamSourcesShown).toEventually(beFalsy())
            for item in view!.availableItems() {
                expect(item.label.alpha).toEventually(equal(0))
            }
        }
    }
    
}
