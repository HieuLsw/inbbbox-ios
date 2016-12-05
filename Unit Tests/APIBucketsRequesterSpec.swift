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
            
            var error: ErrorType?
            var bucket: BucketType?
            
            beforeEach {
                error = nil
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
                    sut.postBucket("fixture.name", description: nil).then { _ in
                        fail("This should not be invoked")
                    }.error { _error in
                        error = _error
                    }
                    
                    expect(error is VerifiableError).toEventually(beTruthy())
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, builder: json(self.fixtureJSON))
                }
                
                it("bucket should be created") {
                    sut.postBucket("fixture.name", description: nil).then { _bucket in
                    bucket = _bucket
                    }.error { _ in fail("This should not be invoked") }
                    
                    expect(bucket).toNotEventually(beNil())
                }
            }
        }
        
        describe("when adding shot to bucket") {
            
            var error: ErrorType?
            var didInvokePromise: Bool?
            
            beforeEach {
                error = nil
                didInvokePromise = nil
            }
            
            context("and token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    sut.addShot(Shot.fixtureShot(), toBucket: Bucket.fixtureBucket()).then {
                        fail()
                    }.error { _error in
                        error = _error
                    }
                    
                    expect(error is VerifiableError).toEventually(beTruthy())
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, builder: json([], status: 204))
                }
                
                it("should add shot to bucket") {
                    sut.addShot(Shot.fixtureShot(), toBucket: Bucket.fixtureBucket()).then {
                        didInvokePromise = true
                    }.error { _ in fail() }
                    
                    expect(didInvokePromise).toEventually(beTruthy(), timeout: 3)
                }
            }
        }
        
        describe("when removing shot from bucket") {
            
            var error: ErrorType?
            var didInvokePromise: Bool?
            
            beforeEach {
                error = nil
                didInvokePromise = nil
            }
            
            context("and token does not exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    sut.removeShot(Shot.fixtureShot(), fromBucket: Bucket.fixtureBucket()).then {
                        fail()
                    }.error { _error in
                        error = _error
                    }
                    
                    expect(error is VerifiableError).toEventually(beTruthy())
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                    self.stub(everything, builder: json([], status: 204))
                }
                
                it("should remove shot from bucket") {
                    sut.removeShot(Shot.fixtureShot(), fromBucket: Bucket.fixtureBucket()).then {
                        didInvokePromise = true
                    }.error { _ in fail() }
                    
                    expect(didInvokePromise).toEventually(beTruthy(), timeout: 3)
                }
            }
        }
    }
}


private extension APIBucketsRequesterSpec {
    
    var fixtureJSON: [String: AnyObject] {
        return JSONSpecLoader.sharedInstance.jsonWithResourceName("Bucket").dictionaryObject!
    }
}
