//
//  ProfileShotsViewModelSpec.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import PromiseKit
import Dobby

@testable import Inbbbox

class ProfileShotsViewModelSpec: QuickSpec {
    
    override func spec() {
        
        var sut: ProfileShotsViewModelMock!
        let fixtureShotImage: ShotImageType = ShotImage(
            hidpiURL: URL(string: "https://fixture.domain/fixture.image.hidpi.png"),
            normalURL: URL(string: "https://fixture.domain/fixture.image.normal.png")!,
            teaserURL: URL(string: "https://fixture.domain/fixture.image.teaser.png")!
        )
        var connectionsRequesterMock: APIConnectionsRequesterMock!
        
        beforeEach {
            sut = ProfileShotsViewModelMock(user: User.fixtureUser())
            connectionsRequesterMock = APIConnectionsRequesterMock()
            sut.connectionsRequester = connectionsRequesterMock
        }
        
        afterEach {
            sut = nil
        }
        
        describe("when newly initialized") {
            
            it("user should be correctly allocated") {
                expect(sut.user.identifier).to(equal(User.fixtureUser().identifier))
            }
            
            it("should have proper number of shots") {
                expect(sut.itemsCount).to(equal(0))
            }
        }
        
        describe("when downloading initial data") {
            
            beforeEach {
                sut.downloadInitialItems()
            }
            
            it("should have proper number of shots") {
                expect(sut.itemsCount).to(equal(2))
            }
            
            it("should return proper cell data for index path") {
                let indexPath = IndexPath(row: 0, section: 0)
                let cellData = sut.shotCollectionViewCellViewData(indexPath)
                expect(cellData.animated).to(equal(true))
                expect(cellData.shotImage.teaserURL).to(equal(fixtureShotImage.teaserURL))
                expect(cellData.shotImage.normalURL).to(equal(fixtureShotImage.normalURL))
                expect(cellData.shotImage.hidpiURL).to(equal(fixtureShotImage.hidpiURL))
            }
        }
        
        describe("When downloading data for next page") {
            
            beforeEach {
                sut.downloadItemsForNextPage()
            }
            
            it("should have proper number of shots") {
                expect(sut.itemsCount).to(equal(3))
            }
            
            it("should return proper shot data for index path") {
                let indexPath = IndexPath(row: 0, section: 0)
                let cellData = sut.shotCollectionViewCellViewData(indexPath)
                expect(cellData.animated).to(equal(true))
                expect(cellData.shotImage.teaserURL).to(equal(fixtureShotImage.teaserURL))
                expect(cellData.shotImage.normalURL).to(equal(fixtureShotImage.normalURL))
                expect(cellData.shotImage.hidpiURL).to(equal(fixtureShotImage.hidpiURL))
            }
        }

        /// In this test, we won't override `downloadItemsForNextPage` method.
        describe("When truly downloading data for next page") {

            let fakeDelegate = ViewModelDelegate()

            beforeEach {
                sut.delegate = fakeDelegate
                sut.shouldCallNextPageDownloadSuper = true
                sut.downloadItemsForNextPage()
            }

            it("should notify delegate about failure") {
                expect(fakeDelegate.didCallDelegate).toEventually(beTrue())
            }
        }
    }
}

//Explanation: Create UserDetailsViewModelMock to override methods from BaseCollectionViewViewModel.

private class ProfileShotsViewModelMock: ProfileShotsViewModel {

    var shouldCallNextPageDownloadSuper = false

    override func downloadInitialItems() {
        let shot = Shot.fixtureShot()
        userShots = [shot, shot]
    }
    
    override func downloadItemsForNextPage() {
        let shot = Shot.fixtureShot()
        userShots = [shot, shot, shot]

        if shouldCallNextPageDownloadSuper {
            super.downloadItemsForNextPage()
        }
    }
}
