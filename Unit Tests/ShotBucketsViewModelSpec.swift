//
//  ShotBucketsViewModelSpec.swift
//  Inbbbox
//
//  Created by Peter Bruz on 28/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import PromiseKit
import Dobby

@testable import Inbbbox

class ShotBucketsViewModelSpec: QuickSpec {

    override func spec() {
        
        var sut: ShotBucketsViewModel!
        var shot: ShotType!
        var bucketsProviderMock: BucketsProviderMock!
        var bucketsRequesterMock: BucketsRequesterMock!
        var shotsRequesterMock: APIShotsRequesterMock!
        
        beforeEach {
            
            shot = Shot.fixtureShot()
            bucketsProviderMock = BucketsProviderMock()
            bucketsRequesterMock = BucketsRequesterMock()
            shotsRequesterMock = APIShotsRequesterMock()
            
            bucketsProviderMock.provideMyBucketsStub.on(any()) { _ in
                return Promise{ fulfill, _ in
                    
                    let json = JSONSpecLoader.sharedInstance.fixtureBucketsJSON(withCount: 2)
                    let result = json.map { Bucket.map($0) }
                    var resultBucketTypes = [BucketType]()
                    for bucket in result {
                        resultBucketTypes.append(bucket)
                    }
                    
                    fulfill(resultBucketTypes)
                }
            }
            
            bucketsRequesterMock.postBucketStub.on(any()) { _ in
                let json = JSONSpecLoader.sharedInstance.fixtureBucketsJSON(withCount: 1)
                let result = json.map { Bucket.map($0) }
                var resultBucketTypes = [BucketType]()
                for bucket in result {
                    resultBucketTypes.append(bucket)
                }
                
                return Promise(resultBucketTypes.first!)
                
            }
            
            bucketsRequesterMock.addShotStub.on(any()) { _ in
                return Promise()
            }
            
            bucketsRequesterMock.removeShotStub.on(any()) { _ in
                return Promise()
            }
            
            shotsRequesterMock.userBucketsForShotStub.on(any()) { _ in
                return Promise{ fulfill, _ in
                    
                    let json = JSONSpecLoader.sharedInstance.fixtureBucketsJSON(withCount: 3)
                    let result = json.map { Bucket.map($0) }
                    var resultBucketTypes = [BucketType]()
                    for bucket in result {
                        resultBucketTypes.append(bucket)
                    }
                    
                    fulfill(resultBucketTypes)
                }
            }
        }
        
        afterEach {
            bucketsProviderMock = nil
            bucketsRequesterMock = nil
            shotsRequesterMock = nil
            shot = nil
        }
        
        context("adding shot to bucket") {
            
            beforeEach {
                sut = ShotBucketsViewModel(shot: shot, mode: .AddToBucket)
                
                sut.bucketsProvider = bucketsProviderMock
                sut.bucketsRequester = bucketsRequesterMock
                sut.bucketsProvider.provideMyBuckets()
            }
            
            afterEach {
                sut = nil
            }
            
            describe("when newly initialized") {
                
                it("should have correct title") {
                    expect(sut.titleForHeader).to(equal("Add to Bucket"))
                }
                
                it("should have no buckets") {
                    expect(sut.buckets.count).to(equal(0))
                }
                
                it("should have correct number of items") {
                    waitUntil { done in
                        sut.loadBuckets().then { _ in
                            done()
                        }
                    }

                    expect(sut.itemsCount >= 2).to(beTruthy())
                }
            }
            
            describe("when buckets are loaded") {
                
                var didReceiveResponse: Bool?
                
                beforeEach {
                    didReceiveResponse = false
                    waitUntil { done in
                        sut.loadBuckets().then { result -> Void in
                            didReceiveResponse = true
                            done()
                        }.error { _ in fail("This should not be invoked") }
                    }
                }
                
                afterEach {
                    didReceiveResponse = nil
                }
                
                it("buckets should be properly downloaded") {
                    expect(didReceiveResponse).to(beTruthy())
                    expect(didReceiveResponse).toNot(beNil())
                }
                
                it("view model should have correct number of buckets") {
                    expect(sut.buckets.count).to(equal(2))
                }
                
                it("view model should have correct number of items") {
                    expect(sut.itemsCount).to(equal(4))
                }
            }
            
            describe("when adding shot to bucket") {
                
                var didReceiveResponse: Bool?
                
                beforeEach {
                    didReceiveResponse = false
                    
                    waitUntil { done in
                        sut.loadBuckets().then { result -> Void in
                            done()
                        }.error { _ in fail("This should not be invoked") }
                    }
                    
                    waitUntil { done in
                        sut.addShotToBucketAtIndex(0).then { result -> Void in
                            didReceiveResponse = true
                            done()
                        }.error { _ in fail("This should not be invoked") }
                    }
                }
                
                afterEach {
                    didReceiveResponse = nil
                }
                
                it("should be correctly added") {
                    expect(didReceiveResponse).to(beTruthy())
                    expect(didReceiveResponse).toNot(beNil())
                }
            }
            
            describe("adding shot to new bucket") {
                
                var didReceiveResponse: Bool?
                var didCreateBucket: Bool?
                
                beforeEach {
                    didReceiveResponse = false
                    didCreateBucket = false
                    
                    waitUntil { done in
                        sut.loadBuckets().then { result -> Void in
                            done()
                        }.error { _ in fail("This should not be invoked") }
                    }
                    
                    waitUntil { done in
                        sut.createBucket("fixture.name").then { result -> Void in
                            didCreateBucket = true
                            done()
                        }.error { _ in fail("This should not be invoked") }
                    }
                    
                    waitUntil { done in
                        sut.addShotToBucketAtIndex(2).then { result -> Void in
                            didReceiveResponse = true
                            done()
                        }.error { _ in fail("This should not be invoked") }
                    }
                }
                
                afterEach {
                    didReceiveResponse = nil
                    didCreateBucket = nil
                }
                
                it("should create new bucket properly") {
                    expect(didCreateBucket).to(beTruthy())
                    expect(didCreateBucket).toNot(beNil())
                }
                
                it("should be correctly added") {
                    expect(didReceiveResponse).to(beTruthy())
                    expect(didReceiveResponse).toNot(beNil())
                }
            }
        }
        
        context("removing shot from buckets") {
            
            beforeEach {
                sut = ShotBucketsViewModel(shot: shot, mode: .RemoveFromBucket)
                
                sut.shotsRequester = shotsRequesterMock
                sut.bucketsRequester = bucketsRequesterMock
            }
            
            afterEach {
                sut = nil
            }
            
            describe("when newly initialized") {
                
                it("should have correct title") {
                    expect(sut.titleForHeader).to(equal("Remove from Bucket"))
                }
                
                it("should have no buckets") {
                    expect(sut.buckets.count).to(equal(0))
                }
                
                it("should have correct number of items") {
                    waitUntil { done in
                        sut.loadBuckets().then { _ in
                            done()
                        }
                    }

                    expect(sut.itemsCount >= 2).to(beTruthy())
                }
            }
            
            describe("when buckets for shot are loaded") {
                
                var didReceiveResponse: Bool?
                
                beforeEach {
                    didReceiveResponse = false
                    waitUntil { done in
                        sut.loadBuckets().then { result -> Void in
                            didReceiveResponse = true
                            done()
                        }.error { _ in fail("This should not be invoked") }
                    }
                }
                
                afterEach {
                    didReceiveResponse = nil
                }
                
                it("buckets should be properly downloaded") {
                    expect(didReceiveResponse).to(beTruthy())
                    expect(didReceiveResponse).toNot(beNil())
                }
                
                it("view model should have correct number of buckets") {
                    expect(sut.buckets.count).to(equal(3))
                }
                
                it("view model should have correct number of items") {
                    expect(sut.itemsCount).to(equal(5))
                }
            }
            
            describe("when removing shot from selected buckets") {
                
                var didReceiveResponse: Bool?
                
                beforeEach {
                    didReceiveResponse = false
                    
                    waitUntil { done in
                        sut.loadBuckets().then { result -> Void in
                            done()
                        }.error { _ in fail("This should not be invoked") }
                    }
                    
                    sut.selectBucketAtIndex(0)
                    sut.selectBucketAtIndex(1)
                    
                    waitUntil { done in
                        sut.removeShotFromSelectedBuckets().then { result -> Void in
                            didReceiveResponse = true
                            done()
                        }.error { _ in fail("This should not be invoked") }
                    }
                }
                
                afterEach {
                    didReceiveResponse = nil
                }
                
                it("shot should be properly removed from selected buckets") {
                    expect(didReceiveResponse).to(beTruthy())
                    expect(didReceiveResponse).toNot(beNil())
                }
            }
        }
    }
}
