//
//  APITeamsProviderSpec.swift
//  Inbbbox
//
//  Created by Peter Bruz on 10/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import PromiseKit
import Dobby

@testable import Inbbbox

class APITeamsProviderSpec: QuickSpec {
    override func spec() {
        
        var sut: APITeamsProviderPrivateMock!
        
        beforeEach {
            sut = APITeamsProviderPrivateMock()
        }
        
        afterEach {
            sut = nil
        }
        
        describe("when providing members for team") {
            
            it("members should be properly returned") {
                let promise = sut.provideMembers(forTeam: Team.fixtureTeam())
                
                expect(promise).to(resolveWithValueMatching { users in
                    expect(users).toNot(beNil())
                    expect(users).to(haveCount(3))
                })
            }
            
        }
        
        describe("when providing members from next page") {
            
            it("members should be properly returned") {
                let promise = sut.nextPage()
                
                expect(promise).to(resolveWithValueMatching { users in
                    expect(users).toNot(beNil())
                    expect(users).to(haveCount(3))
                })
            }
        }
        
        describe("when providing members from previous page") {
            
            it("members should be properly returned") {
                let promise = sut.previousPage()
                
                expect(promise).to(resolveWithValueMatching { users in
                    expect(users).toNot(beNil())
                    expect(users).to(haveCount(3))
                })
            }
        }
    }
}

//Explanation: Create APITeamsProviderPrivateMock to override methods from PageableProvider.
private class APITeamsProviderPrivateMock: APITeamsProvider {
    
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
            
            let json = JSONSpecLoader.sharedInstance.fixtureUsersJSON(withCount: 3)
            let result = json.map { T.map($0) }
            
            fulfill(result)
        }
    }
}
