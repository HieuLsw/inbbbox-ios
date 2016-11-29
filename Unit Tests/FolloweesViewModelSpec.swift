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
                expect(cellData.shotsImagesURLs).to(equal(fixtureImagesURLs))
                expect(cellData.avatarURL).to(equal(fixtureAvatarURL))
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
                let indexPath = IndexPath(row: 1, section: 0)
                let cellData = sut.followeeCollectionViewCellViewData(indexPath)
                expect(cellData.name).to(equal(fixtureFolloweeName))
                expect(cellData.numberOfShots).to(equal(fixtureNumberOfShots))
                expect(cellData.shotsImagesURLs).to(equal(fixtureImagesURLs))
                expect(cellData.avatarURL).to(equal(fixtureAvatarURL))
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

//Explanation: Create mock class to override methods from BaseCollectionViewViewModel.

private class FolloweesViewModelMock: FolloweesViewModel {

    var shouldCallNextPageDownloadSuper = false

    override func downloadInitialItems() {
        let followee = User.fixtureUser()
        followees = [followee, followee]
        downloadShots(followees)
    }

    override func downloadItemsForNextPage() {
        let followee = User.fixtureUser()
        followees = [followee, followee, followee]
        downloadShots(followees)

        if shouldCallNextPageDownloadSuper {
            super.downloadItemsForNextPage()
        }
    }

    override func downloadShots(_ followees: [Followee]) {
        for index in 0...followees.count - 1 {
            followeesIndexedShots[index] = [Shot.fixtureShot()]
        }
    }
}
