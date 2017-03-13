//
//  ShotsProviderSpec.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Nimble
import Quick
import PromiseKit

@testable import Inbbbox

class APIShotsProviderSpec: QuickSpec {
    override func spec() {
        
        var sut: APIShotsProviderPrivateMock!
        
        beforeEach {
            sut = APIShotsProviderPrivateMock()
        }
        
        afterEach {
            sut = nil
        }
        
        describe("when providing shots") {
            
            it("shots should be properly returned") {
                let promise = sut.provideShots()
                
                expect(promise).to(resolveWithValueMatching { shots in
                    expect(shots).toNot(beNil())
                    expect(shots).to(haveCount(3))
                })
            }
        }
        
        describe("when providing my liked shots") {
            
            context("and token doesn't exist") {
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                it("error should appear") {
                    let promise = sut.provideMyLikedShots()
                    expect(promise).to(resolveWithError(type: VerifiableError.self))
                }
            }

            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                }
                
                it("shots should be properly returned") {
                    let promise = sut.provideMyLikedShots()
                    
                    expect(promise).to(resolveWithValueMatching { shots in
                        expect(shots).toNot(beNil())
                        expect(shots).to(haveCount(3))
                    })
                }
            }
        }
        
        describe("when providing shots for user") {
            
            it("shots should be properly returned") {
                let promise = sut.provideShotsForUser(User.fixtureUser())
                
                expect(promise).to(resolveWithValueMatching { shots in
                    expect(shots).toNot(beNil())
                    expect(shots).to(haveCount(3))
                })
            }
        }
        
        describe("when providing liked shots for user") {
            
            it("shots should be properly returned") {
                let promise = sut.provideLikedShotsForUser(User.fixtureUser())
                
                expect(promise).to(resolveWithValueMatching { shots in
                    expect(shots).toNot(beNil())
                    expect(shots).to(haveCount(3))
                })
            }
        }
        
        describe("when providing shots for bucket") {
            
            it("shots should be properly returned") {
                let promise = sut.provideShotsForBucket(Bucket.fixtureBucket())
                
                expect(promise).to(resolveWithValueMatching { shots in
                    expect(shots).toNot(beNil())
                    expect(shots).to(haveCount(3))
                })
            }
        }
        
        describe("when providing shots for project") {

            it("shots should be properly returned") {
                let promise = sut.provideShotsForProject(Project.fixtureProject())
                
                expect(promise).to(resolveWithValueMatching { shots in                    expect(shots).toNot(beNil())
                    expect(shots).to(haveCount(3))
                })
            }
        }

        describe("when providing shots from next/previous page") {
            
            context("without using any of provide method first") {
                
                it("should raise an error") {
                    let promise = sut.nextPage()
                    expect(promise).to(resolveWithError(type: PageableProviderError.self))
                }
                
                it("should raise an error") {
                    let promise = sut.previousPage()
                    expect(promise).to(resolveWithError(type: PageableProviderError.self))
                }
            }
            
            context("with using provide method first") {
                
                beforeEach {
                    _ = sut.provideShots()
                }
                
                it("shots should be properly returned") {
                    let promise = sut.nextPage()
                    
                    expect(promise).to(resolveWithValueMatching { shots in
                        expect(shots).toNot(beNil())
                        expect(shots).to(haveCount(3))
                    })
                }
                
                
                it("shots should be properly returned") {
                    let promise = sut.previousPage()
                    
                    expect(promise).to(resolveWithValueMatching { shots in
                        expect(shots).toNot(beNil())
                        expect(shots).to(haveCount(3))
                    })
                }
                
            }
        }
    }
}

//Explanation: Create ShotsProviderMock to override methods from PageableProvider.
private class APIShotsProviderPrivateMock: APIShotsProvider {
    
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
            
            let configuration = [
                (identifier: 1, animated: true),
                (identifier: 2, animated: false),
                (identifier: 3, animated: false),
                (identifier: 3, animated: false)
            ]
            
            let json = JSONSpecLoader.sharedInstance.fixtureShotJSON(configuration)
            let result = json.map { T.map($0) }
            
            fulfill(result)
        }
    }
}
