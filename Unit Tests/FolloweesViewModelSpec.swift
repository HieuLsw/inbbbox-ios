//
//  FolloweesViewModelSpec.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 01.03.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class FolloweesViewModelSpec: QuickSpec {

    override func spec() {

        var sut: FolloweesViewModelMock!
        let fixtureImageURL = URL(string: "https://fixture.domain/fixture.image.teaser.png")
        let fixtureImagesURLs: [URL]? = [fixtureImageURL!, fixtureImageURL!, fixtureImageURL!, fixtureImageURL!]
        let fixtureFolloweeName = "fixture.name"
        let fixtureNumberOfShots = "1 shot"
        let fixtureAvatarURL = URL(string:"fixture.avatar.url")

        beforeEach {
            sut = FolloweesViewModelMock()
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

            it("should have proper number of followees") {
                expect(sut.itemsCount).to(equal(2))
            }

            it("should return proper cell data for index path") {
                let indexPath = IndexPath(row: 0, section: 0)
                let cellData = sut.followeeCollectionViewCellViewData(indexPath)
                expect(cellData.name).to(equal(fixtureFolloweeName))
                expect(cellData.numberOfShots).to(equal(fixtureNumberOfShots))
                expect(cellData.avatarURL).to(equal(fixtureAvatarURL))
            }
        }

        describe("When downloading data for next visible cells") {

            beforeEach {
                sut.downloadInitialItems()
                sut.downloadItem(at: 0)
                sut.downloadItem(at: 1)
            }

            it("should have proper number of shots") {
                expect(sut.itemsCount).to(equal(2))
            }

            it("should return proper shot data for index path") {
                let indexPath = IndexPath(row: 1, section: 0)
                let cellData = sut.followeeCollectionViewCellViewData(indexPath)
                expect(cellData.name).to(equal(fixtureFolloweeName))
                expect(cellData.numberOfShots).to(equal(fixtureNumberOfShots))
                expect(cellData.shotsImagesURLs).to(equal(fixtureImagesURLs))
                expect(cellData.avatarURL).to(equal(fixtureAvatarURL))
            }
        }
        
        describe("When truly downloading data for next cell") {
            
            let fakeDelegate = ViewModelDelegate()

            beforeEach {
                sut.delegate = fakeDelegate
                sut.shouldCallNextPageDownloadSuper = true
                sut.downloadInitialItems()
                sut.downloadItem(at: 0)
            }

            it("should notify delegate about failure") {
                expect(fakeDelegate.didCallDelegate).toEventually(beTrue())
            }
        }
    }
}

//Explanation: Create mock class to override methods from BaseCollectionViewViewModel.

private class FolloweesViewModelMock: FolloweesViewModel {

    var shouldCallNextPageDownloadSuper = false

    override func downloadInitialItems() {
        let followee = User.fixtureUser()
        followees = [followee, followee]
    }
    
    override func downloadItem(at index: Int) {
        guard !shouldCallNextPageDownloadSuper else {
            super.downloadItem(at: 1)
            return
        }
        
        followeesIndexedShots[index] = [Shot.fixtureShot()]
    }
}
