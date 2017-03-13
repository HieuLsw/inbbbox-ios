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
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    let promise = sut.provideMyBuckets()
                    expect(promise).to(resolveWithError(type: VerifiableError.self))
                }
            }
            
            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                }
                
                it("buckets should be properly returned") {
                    let promise = sut.provideMyBuckets()
                    
                    expect(promise).to(resolveWithValueMatching { buckets in
                        expect(buckets).toNot(beNil())
                        expect(buckets).to(haveCount(3))
                        expect(buckets?.first?.identifier).to(equal("1"))
                    })
                }
            }
        }
        
        describe("when providing buckets for user") {
            
            beforeEach {
                TokenStorage.storeToken("fixture.token")
            }
            
            context("for user") {
                
                it("buckets should be properly returned") {
                    let promise = sut.provideBucketsForUser(User.fixtureUser())
                    
                    expect(promise).to(resolveWithValueMatching { buckets in
                        expect(buckets).toNot(beNil())
                        expect(buckets).to(haveCount(3))
                        expect(buckets?.first?.identifier).to(equal("1"))
                    })
                }
            }
            
            context("for users") {
                
                it("buckets should be properly returned") {
                    let promise = sut.provideBucketsForUsers([User.fixtureUser(), User.fixtureUser()])
                    
                    expect(promise).to(resolveWithValueMatching { buckets in
                        expect(buckets).toNot(beNil())
                        expect(buckets).to(haveCount(3))
                        expect(buckets?.first?.identifier).to(equal("1"))
                    })
                }
            }
            
            context("for the next page") {
                
                it("buckets should be properly returned") {
                    let promise = sut.nextPage()
                    
                    expect(promise).to(resolveWithValueMatching { buckets in
                        expect(buckets).toNot(beNil())
                        expect(buckets).to(haveCount(3))
                        expect(buckets?.first?.identifier).to(equal("1"))
                    })
                }
            }
            
            context("for the previous page") {
                
                it("buckets should be properly returned") {
                    let promise = sut.previousPage()
                    
                    expect(promise).to(resolveWithValueMatching { buckets in
                        expect(buckets).toNot(beNil())
                        expect(buckets).to(haveCount(3))
                        expect(buckets?.first?.identifier).to(equal("1"))
                    })
                }
            }
        }
    }
}

//Explanation: Create BucketsProviderPrivateMock to override methods from PageableProvider.
private class APIBucketsProviderPrivateMock: APIBucketsProvider {
    
    override func firstPageForQueries<T: Mappable>(_ queries: [Query], withSerializationKey key: String?) -> Promise<[T]?> {
        return mockResult(T.self)
    }
    
    override func nextPageFor<T: Mappable>(_ type: T.Type) -> Promise<[T]?> {
        return mockResult(T.self)
    }
    
    override func previousPageFor<T: Mappable>(_ type: T.Type) -> Promise<[T]?> {
        return mockResult(T.self)
    }
    
    func mockResult<T: Mappable>(_ type: T.Type) -> Promise<[T]?> {
        return Promise<[T]?> { fulfill, _ in
            
            let json = JSONSpecLoader.sharedInstance.fixtureBucketsJSON(withCount: 3)
            let result = json.map { T.map($0) }
            
            fulfill(result)
        }
    }
}
