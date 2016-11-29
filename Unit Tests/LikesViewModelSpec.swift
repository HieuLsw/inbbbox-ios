//
//  LikesViewModelSpec.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 29.02.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class LikesViewModelSpec: QuickSpec {
    
    override func spec() {
        
        var sut: LikesViewModelMock!
        let fixtureShotImage: ShotImageType = ShotImage(
            hidpiURL: URL(string: "https://fixture.domain/fixture.image.hidpi.png"),
            normalURL: URL(string: "https://fixture.domain/fixture.image.normal.png")!,
            teaserURL: URL(string: "https://fixture.domain/fixture.image.teaser.png")!
        )
        
        beforeEach {
           sut = LikesViewModelMock()
        }
        
        afterEach {
           sut = nil
        }
        
        describe("When initialized") {
            
            it("should have proper number of shots") {
                expect(sut.itemsCount).to(equal(0))
            }
        }
        
        describe("When downloading initial data") {
                
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

//Explanation: Create LikesViewModelMock to override methods from BaseCollectionViewViewModel.

private class LikesViewModelMock: LikesViewModel {

    var shouldCallNextPageDownloadSuper = false

    override func downloadInitialItems() {
        let shot = Shot.fixtureShot()
        shots = [shot, shot]
    }
    
    override func downloadItemsForNextPage() {
        let shot = Shot.fixtureShot()
        shots = [shot, shot, shot]

        if shouldCallNextPageDownloadSuper {
            super.downloadItemsForNextPage()
        }
    }
}
