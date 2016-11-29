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
        
        var users: [UserType]?
        var sut: APITeamsProviderPrivateMock!
        
        beforeEach {
            sut = APITeamsProviderPrivateMock()
        }
        
        afterEach {
            sut = nil
            users = nil
        }
        
        describe("when providing members for team") {
            
            it("members should be properly returned") {
                sut.provideMembersForTeam(Team.fixtureTeam()).then { _users -> Void in
                    users = _users
                }.catch { _ in fail("This should not be invoked") }
                
                expect(users).toNotEventually(beNil())
                expect(users).toEventually(haveCount(3))
            }
            
        }
        
        describe("when providing members from next page") {
            
            it("members should be properly returned") {
                sut.nextPage().then { _users -> Void in
                    users = _users
                }.catch { _ in fail("This should not be invoked") }
                
                expect(users).toNotEventually(beNil())
                expect(users).toEventually(haveCount(3))
            }
        }
        
        describe("when providing members from previous page") {
            
            it("members should be properly returned") {
                sut.previousPage().then { _users -> Void in
                    users = _users
                }.catch { _ in fail("This should not be invoked") }
                
                expect(users).toNotEventually(beNil())
                expect(users).toEventually(haveCount(3))
            }
        }
    }
}

//Explanation: Create APITeamsProviderPrivateMock to override methods from PageableProvider.
private class APITeamsProviderPrivateMock: APITeamsProvider {
    
    override func firstPageForQueries<T: Mappable>(_ queries: [Query], withSerializationKey key: String?) -> Promise<[T]?> {
        return mockResult(T)
    }
    
    override func nextPageFor<T: Mappable>(_ type: T.Type) -> Promise<[T]?> {
        return mockResult(T)
    }
    
    override func previousPageFor<T: Mappable>(_ type: T.Type) -> Promise<[T]?> {
        return mockResult(T)
    }
    
    func mockResult<T: Mappable>(_ type: T.Type) -> Promise<[T]?> {
        return Promise<[T]?> { fulfill, _ in
            
            let json = JSONSpecLoader.sharedInstance.fixtureUsersJSON(withCount: 3)
            let result = json.map { T.map($0) }
            
            fulfill(result)
        }
    }
}
