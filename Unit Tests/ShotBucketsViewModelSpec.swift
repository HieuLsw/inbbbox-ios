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
                
                return Promise(value: resultBucketTypes.first!)
                
            }
            
            bucketsRequesterMock.addShotStub.on(any()) { _ in
                return Promise<Void>(value: Void())
            }
            
            bucketsRequesterMock.removeShotStub.on(any()) { _ in
                return Promise<Void>(value: Void())
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
                sut = ShotBucketsViewModel(shot: shot, mode: .addToBucket)
                
                sut.bucketsProvider = bucketsProviderMock
                sut.bucketsRequester = bucketsRequesterMock
                _ = sut.bucketsProvider.provideMyBuckets()
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
                
            }
            
            describe("when buckets are loaded") {
                
                it("buckets should be properly downloaded and stored") {
                    let promise = sut.loadBuckets()
                    
                    expect(promise).to(resolveWithValueMatching { _ in
                        expect(sut.buckets).to(haveCount(2))
                        expect(sut.itemsCount).to(equal(4))
                    })
                }
            }
            
            describe("when adding shot to bucket") {
                
                it("should be correctly added") {
                    let promise = sut.loadBuckets().then { sut.addShotToBucketAtIndex(0) }
                    
                    expect(promise).to(resolveWithSuccess())
                }
            }
            
            describe("adding shot to new bucket") {

                it("should create new bucket properly") {
                    let promise = sut.loadBuckets().then {
                        sut.createBucket("fixture.name")
                    }.then {
                        sut.addShotToBucketAtIndex(2)
                    }
                    
                    expect(promise).to(resolveWithSuccess())
                }
            }
        }
        
        context("removing shot from buckets") {
            
            beforeEach {
                sut = ShotBucketsViewModel(shot: shot, mode: .removeFromBucket)
                
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
                
            }
            
            describe("when buckets for shot are loaded") {
                
                it("buckets should be properly downloaded and stored") {
                    let promise = sut.loadBuckets()
                    
                    expect(promise).to(resolveWithValueMatching { _ in
                        expect(sut.buckets).to(haveCount(3))
                        expect(sut.itemsCount).to(equal(5))
                    })
                }
            }
            
            describe("when removing shot from selected buckets") {
                
                it("shot should be properly removed from selected buckets") {
                    let promise = sut.loadBuckets().then { _ -> Void in
                        _ = sut.selectBucketAtIndex(0)
                        _ = sut.selectBucketAtIndex(1)
                    }.then {
                        sut.removeShotFromSelectedBuckets()
                    }
                    
                    expect(promise).to(resolveWithSuccess())
                }
            }
        }
    }
}
