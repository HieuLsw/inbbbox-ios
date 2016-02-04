//
//  BucketsProviderSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 04/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import PromiseKit

@testable import Inbbbox

class BucketsProviderSpec: QuickSpec {
    override func spec() {
        
        var sut: MockBucketsProvider!
        
        beforeEach {
            sut = MockBucketsProvider()
        }
        
        afterEach {
            sut = nil
        }
        
        describe("when using next/previous page without specyfing provide method") {
            
            var error: ErrorType?
            
            afterEach {
                error = nil
            }
            
            it("error should appear") {
                sut.nextPage().then { _ -> Void in
                    fail()
                }.error { _error in
                    error = _error
                }
                
                expect(error is PageableProviderError).toEventually(beTruthy())
            }
            
            it("error should appear") {
                sut.previousPage().then { _ -> Void in
                    fail()
                }.error { _error in
                    error = _error
                }
                
                expect(error is PageableProviderError).toEventually(beTruthy())
            }
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
                    
                    expect(error is AuthorizableError).toEventually(beTruthy())
                }
            }
            
            context("and token does exist") {
                
                var buckets: [Bucket]?
                
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
                    
                    expect(buckets).toNotEventually(beNil())
                    expect(buckets).toEventually(haveCount(3))
                    expect(buckets?.first?.identifier).toEventually(equal("1"))
                }
            }
        }
        
        describe("when providing buckets for user") {
                
            var buckets: [Bucket]?
            
            afterEach {
                buckets = nil
            }
            
            it("buckets should be properly returned") {
                sut.provideBucketsForUser(User.fixtureUser()).then { _buckets -> Void in
                    buckets = _buckets
                }.error { _ in fail() }
                
                expect(buckets).toNotEventually(beNil())
                expect(buckets).toEventually(haveCount(3))
                expect(buckets?.first?.identifier).toEventually(equal("1"))
            }
        }
        
        describe("when providing buckets for users") {
            
            var buckets: [Bucket]?
            
            afterEach {
                buckets = nil
            }
            
            it("buckets should be properly returned") {
                sut.provideBucketsForUsers([User.fixtureUser(), User.fixtureUser()]).then { _buckets -> Void in
                    buckets = _buckets
                }.error { _ in fail() }
                
                expect(buckets).toNotEventually(beNil())
                expect(buckets).toEventually(haveCount(3))
                expect(buckets?.first?.identifier).toEventually(equal("1"))
            }
        }
    }
}

//Explanation: Create MockBucketsProvider to ovveride methods from PageableProvider.
private class MockBucketsProvider: BucketsProvider {
    
    override func firstPageForQueries<T: Mappable>(queries: [Query]) -> Promise<[T]?> {
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
