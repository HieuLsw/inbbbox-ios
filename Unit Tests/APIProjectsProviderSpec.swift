//
//  APIProjectsProviderSpec.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import PromiseKit
import Mockingjay

@testable import Inbbbox

class APIProjectsProviderSpec: QuickSpec {
    override func spec() {
    
        var sut: APIProjectsProviderMock!
        
        beforeEach {
            sut = APIProjectsProviderMock()
        }
        
        afterEach {
            sut = nil
        }
        
        describe("when providing projects for shot") {
            
            it("comments should be properly returned") {
                let promise = sut.provideProjectsForShot(Shot.fixtureShot())
                
                expect(promise).to(resolveWithValueMatching { projects in
                    expect(projects).toNot(beNil())
                    expect(projects).to(haveCount(3))
                })
            }
        }

        describe("when providing projects for user") {

            beforeEach {
                TokenStorage.storeToken("fixture.token")
            }

            context("for user") {

                it("projects should be properly returned") {
                    let promise = sut.provideProjectsForUser(User.fixtureUser())
                    
                    expect(promise).to(resolveWithValueMatching { projects in
                        expect(projects).toNot(beNil())
                        expect(projects).to(haveCount(3))
                        expect(projects?.first?.identifier).to(equal("1"))
                    })
                }
            }

            context("for the next page") {

                it("projects should be properly returned") {
                    let promise = sut.nextPage()
                    
                    expect(promise).to(resolveWithValueMatching { projects in
                        expect(projects).toNot(beNil())
                        expect(projects).to(haveCount(3))
                        expect(projects?.first?.identifier).to(equal("1"))
                    })
                }
            }
        }
    }
}

//Explanation: Create ProjectsProviderMock to override methods from PageableProvider.
private class APIProjectsProviderMock: APIProjectsProvider {
    
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
            
            let json = JSONSpecLoader.sharedInstance.fixtureProjectsJSON(withCount: 3)
            let result = json.map { T.map($0) }
            
            fulfill(result)
        }
    }
}
