//
//  ShotsProviderSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 05/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Nimble
import Quick
import PromiseKit

@testable import Inbbbox

class APIShotsProviderSpec: QuickSpec {
    override func spec() {
        
        var sut: APIShotsProviderPrivateMock!
        var shots: [ShotType]?
        
        beforeEach {
            sut = APIShotsProviderPrivateMock()
        }
        
        afterEach {
            sut = nil
            shots = nil
        }
        
        describe("when providing shots") {
            
            it("shots should be properly returned") {
                sut.provideShots().then { _shots -> Void in
                    shots = _shots
                }.catch { _ in fail() }
                
                expect(shots).toNotEventually(beNil())
                expect(shots).toEventually(haveCount(3))
            }
        }
        
        describe("when providing my liked shots") {
            
            context("and token doesn't exist") {
                
                var error: Error?
                
                beforeEach {
                    TokenStorage.clear()
                }
                
                afterEach {
                    error = nil
                }
                
                it("error should appear") {
                    sut.provideMyLikedShots().then { _ -> Void in
                        fail()
                    }.catch { _error in
                        error = _error
                    }

                    expect(error is VerifiableError).toEventually(beTruthy())
                }
            }

            context("and token does exist") {
                
                beforeEach {
                    TokenStorage.storeToken("fixture.token")
                }
                
                afterEach {
                    shots = nil
                }
                
                it("shots should be properly returned") {
                    sut.provideMyLikedShots().then { _shots -> Void in
                        shots = _shots
                    }.catch { _ in fail() }
                    
                    expect(shots).toNotEventually(beNil())
                    expect(shots).toEventually(haveCount(3))
                }
            }
        }
        
        describe("when providing shots for user") {
            
            it("shots should be properly returned") {
                sut.provideShotsForUser(User.fixtureUser()).then { _shots -> Void in
                    shots = _shots
                }.catch { _ in fail() }
                
                expect(shots).toNotEventually(beNil())
                expect(shots).toEventually(haveCount(3))
            }
        }
        
        describe("when providing liked shots for user") {
            
            it("shots should be properly returned") {
                sut.provideLikedShotsForUser(User.fixtureUser()).then { _shots -> Void in
                    shots = _shots
                }.catch { _ in fail() }
                
                expect(shots).toNotEventually(beNil())
                expect(shots).toEventually(haveCount(3))
            }
        }
        
        describe("when providing shots for bucket") {
            
            it("shots should be properly returned") {
                sut.provideShotsForBucket(Bucket.fixtureBucket()).then { _shots -> Void in
                    shots = _shots
                }.catch { _ in fail() }
                
                expect(shots).toNotEventually(beNil())
                expect(shots).toEventually(haveCount(3))
            }
        }
        
        describe("when providing shots for project") {

            it("shots should be properly returned") {
                sut.provideShotsForProject(Project.fixtureProject()).then { _shots -> Void in
                    shots = _shots
                }.catch { _ in fail() }

                expect(shots).toNotEventually(beNil())
                expect(shots).toEventually(haveCount(3))
            }
        }

        describe("when providing shots from next/previous page") {
            
            var error: Error!
            
            afterEach {
                error = nil
            }
            
            context("without using any of provide method first") {
                
                it("should raise an error") {
                    sut.nextPage().then { _ -> Void in
                        fail()
                    }.catch { _error in
                        error = _error
                    }
                    
                    expect(error is PageableProviderError).toEventually(beTruthy())
                }
                
                it("should raise an error") {
                    sut.previousPage().then { _ -> Void in
                        fail()
                    }.catch { _error in
                        error = _error
                    }
                    
                    expect(error is PageableProviderError).toEventually(beTruthy())
                }
            }
            
            context("with using provide method first") {
                
                beforeEach {
                    _ = sut.provideShots()
                }
                
                it("shots should be properly returned") {
                    sut.nextPage().then { _shots -> Void in
                        shots = _shots
                    }.catch { _ in fail() }
                    
                    expect(shots).toNotEventually(beNil())
                    expect(shots).toEventually(haveCount(3))
                }
                
                
                it("shots should be properly returned") {
                    sut.previousPage().then { _shots -> Void in
                        shots = _shots
                    }.catch { _ in fail() }
                    
                    expect(shots).toNotEventually(beNil())
                    expect(shots).toEventually(haveCount(3))
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
