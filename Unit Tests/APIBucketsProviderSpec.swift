//
//  APIBucketsProviderSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 04/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import PromiseKit

@testable import Inbbbox

class APIBucketsProviderSpec: QuickSpec {
    override func spec() {

        var sut: APIBucketsProviderPrivateMock!
        
        beforeEach {
            sut = APIBucketsProviderPrivateMock()
        }
        
        afterEach {
            sut = nil
        }
        
        describe("when providing my buckets") {
            
            context("and token doesn't exist") {
                
                var error: ErrorType?
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                afterEach {
                    error = nil
                }
                
                it("error should appear") {
                    sut.provideMyBuckets().then { _ -> Void in
                        fail()
                    }.error { _error in
                        error = _error
                    }
                    
                    expect(error is VerifiableError).toEventually(beTruthy())
                }
            }
            
            context("and token does exist") {
                
                var buckets: [BucketType]?
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                }
                
                afterEach {
                    buckets = nil
                }
                
                it("buckets should be properly returned") {
                    sut.provideMyBuckets().then { _buckets -> Void in
                        buckets = _buckets
                    }.error { _ in fail() }
                    
                    expect(buckets).toNotEventually(beNil(), timeout: 5)
                    expect(buckets).toEventually(haveCount(3))
                    expect(buckets?.first?.identifier).toEventually(equal("1"))
                }
            }
        }
        
        describe("when providing buckets for user") {
            
            
            var buckets: [BucketType]?
            
            beforeEach {
                TokenStorage.storeToken("fixture.token")
            }
            
            afterEach {
                buckets = nil
            }
            
            context("for user") {
                
                it("buckets should be properly returned") {
                    sut.provideBucketsForUser(User.fixtureUser()).then { _buckets -> Void in
                        buckets = _buckets
                    }.error { _ in fail() }
                    
                    expect(buckets).toNotEventually(beNil())
                    expect(buckets).toEventually(haveCount(3))
                    expect(buckets?.first?.identifier).toEventually(equal("1"))
                }
            }
            
            context("for users") {
                
                it("buckets should be properly returned") {
                    sut.provideBucketsForUsers([User.fixtureUser(), User.fixtureUser()]).then { _buckets -> Void in
                        buckets = _buckets
                    }.error { _ in fail() }
                    
                    expect(buckets).toNotEventually(beNil())
                    expect(buckets).toEventually(haveCount(3))
                    expect(buckets?.first?.identifier).toEventually(equal("1"))
                }
            }
            
            context("for the next page") {
                
                it("buckets should be properly returned") {
                    sut.nextPage().then { _buckets -> Void in
                        buckets = _buckets
                    }.error { _ in fail() }
                    
                    expect(buckets).toNotEventually(beNil())
                    expect(buckets).toEventually(haveCount(3))
                    expect(buckets?.first?.identifier).toEventually(equal("1"))
                }
            }
            
            context("for the previous page") {
                
                it("buckets should be properly returned") {
                    sut.previousPage().then { _buckets -> Void in
                        buckets = _buckets
                    }.error { _ in fail() }
                    
                    expect(buckets).toNotEventually(beNil())
                    expect(buckets).toEventually(haveCount(3))
                    expect(buckets?.first?.identifier).toEventually(equal("1"))
                }
            }
        }
    }
}

//Explanation: Create BucketsProviderPrivateMock to override methods from PageableProvider.
private class APIBucketsProviderPrivateMock: APIBucketsProvider {
    
    override func firstPageForQueries<T: Mappable>(queries: [Query], withSerializationKey key: String?) -> Promise<[T]?> {
        return mockResult(T)
    }
    
    override func nextPageFor<T: Mappable>(type: T.Type) -> Promise<[T]?> {
        return mockResult(T)
    }
    
    override func previousPageFor<T: Mappable>(type: T.Type) -> Promise<[T]?> {
        return mockResult(T)
    }
    
    func mockResult<T: Mappable>(type: T.Type) -> Promise<[T]?> {
        return Promise<[T]?> { fulfill, _ in
            
            let json = JSONSpecLoader.sharedInstance.fixtureBucketsJSON(withCount: 3)
            let result = json.map { T.map($0) }
            
            fulfill(result)
        }
    }
}
