//
//  APIBucketsRequesterSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 16/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import PromiseKit
import Mockingjay

@testable import Inbbbox

class APIBucketsRequesterSpec: QuickSpec {
    override func spec() {
        
        var sut: APIBucketsRequester!
        
        beforeEach {
            sut = APIBucketsRequester()
        }
        
        afterEach {
            sut = nil
            self.removeAllStubs()
        }
        
        describe("when posting new bucket") {
            var bucket: BucketType?
            
            beforeEach {
                bucket = nil
            }
            
            afterEach {
                bucket = nil
            }
            
            context("and token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    let promise = sut.postBucket("fixture.name", description: nil)
                    expect(promise).to(resolveWithError(type: VerifiableError.self))
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json(self.fixtureJSON))
                }
                
                it("bucket should be created") {
                    sut.postBucket("fixture.name", description: nil).then { _bucket in
                    bucket = _bucket
                    }.catch { _ in fail("This should not be invoked") }
                    
                    expect(bucket).toNotEventually(beNil())
                }
            }
        }
        
        describe("when adding shot to bucket") {
            context("and token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    let promise = sut.addShot(Shot.fixtureShot(), toBucket: Bucket.fixtureBucket())
                    expect(promise).to(resolveWithError(type: VerifiableError.self))
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json([], status: 204))
                }
                
                it("should add shot to bucket") {
                    let promise = sut.addShot(Shot.fixtureShot(), toBucket: Bucket.fixtureBucket())
                    expect(promise).to(resolveWithSuccess())
                }
            }
        }
        
        describe("when removing shot from bucket") {
            context("and token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    let promise = sut.removeShot(Shot.fixtureShot(), fromBucket: Bucket.fixtureBucket())
                    expect(promise).to(resolveWithError(type: VerifiableError.self))
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, json([], status: 204))
                }
                
                it("should remove shot from bucket") {
                    let promise = sut.removeShot(Shot.fixtureShot(), fromBucket: Bucket.fixtureBucket())
                    expect(promise).to(resolveWithSuccess())
                }
            }
        }
    }
}


private extension APIBucketsRequesterSpec {
    
    var fixtureJSON: [String: AnyObject] {
        return JSONSpecLoader.sharedInstance.jsonWithResourceName("Bucket").dictionaryObject! as [String : AnyObject]
    }
}
