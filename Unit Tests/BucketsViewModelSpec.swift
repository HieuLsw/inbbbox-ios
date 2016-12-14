//
//  BucketsViewModelSpec.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 01.03.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class BucketsViewModelSpec: QuickSpec {
    
    override func spec() {
        
        var sut: BucketsViewModelMock!
        let fixtureImageURL = URL(string: "https://fixture.domain/fixture.image.teaser.png")
        let fixtureImagesURLs: [URL]? = [fixtureImageURL!, fixtureImageURL!, fixtureImageURL!, fixtureImageURL!]
        let fixtureBucketName = "fixture.name"
        let fixtureNumberOfShots = "250 shots"
        
        beforeEach {
            sut = BucketsViewModelMock()
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
            
            it("should have proper number of buckets") {
                expect(sut.itemsCount).to(equal(2))
            }
            
            it("should return proper cell data for index path") {
                let indexPath = IndexPath(row: 0, section: 0)
                let cellData = sut.bucketCollectionViewCellViewData(indexPath)
                expect(cellData.name).to(equal(fixtureBucketName))
                expect(cellData.numberOfShots).to(equal(fixtureNumberOfShots))
                expect(cellData.shotsImagesURLs).to(equal(fixtureImagesURLs))
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
                let cellData = sut.bucketCollectionViewCellViewData(indexPath)
                expect(cellData.name).to(equal(fixtureBucketName))
                expect(cellData.numberOfShots).to(equal(fixtureNumberOfShots))
                expect(cellData.shotsImagesURLs).to(equal(fixtureImagesURLs))
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

private class BucketsViewModelMock: BucketsViewModel {

    var shouldCallNextPageDownloadSuper = false

    override func downloadInitialItems() {
        let bucket = Bucket.fixtureBucket()
        buckets = [bucket, bucket]
        buckets.forEach { downloadShots($0) }
    }
    
    override func downloadItemsForNextPage() {
        let bucket = Bucket.fixtureBucket()
        buckets = [bucket, bucket, bucket]
        buckets.forEach { downloadShots($0) }

        if shouldCallNextPageDownloadSuper {
            super.downloadItemsForNextPage()
        }
    }
    
    override func downloadShots(_ bucket: BucketType) {
        var indexOfBucket: Int?
        for (index, item) in self.buckets.enumerated() {
            if item.identifier == bucket.identifier {
                indexOfBucket = index
                break
            }
        }
        guard let index = indexOfBucket else { return }
        bucketsIndexedShots[index] = [Shot.fixtureShot()]
    }
}
