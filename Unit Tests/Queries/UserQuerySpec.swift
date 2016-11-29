//
//  UserQuerySpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 30/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class UserQuerySpec: QuickSpec {
    override func spec() {
        
        var sut: UserQuery!
        
        afterEach {
            sut = nil
        }
        
        describe("when newly initialized with identifier") {
            
            SharedQuerySpec.performSpecForQuery( { Void -> Query in
                return UserQuery(identifier: "fixture.identifier")
            }) { Void -> QueryExpectation in
                return (method: .GET, encoding: .url, path: "/users/fixture.identifier")
            }
            
            beforeEach {
                sut = UserQuery(identifier: "fixture.identifier")
            }
            
            it("should have empty parameters") {
                expect(sut.parameters.queryItems).to(beEmpty())
            }
        }
        
        describe("when newly initialized") {

            SharedQuerySpec.performSpecForQuery( { Void -> Query in
                return UserQuery()
            }) { Void -> QueryExpectation in
                return (method: .GET, encoding: .url, path: "/user")
            }
            
            beforeEach {
                sut = UserQuery()
            }
            
            it("should have empty parameters") {
                expect(sut.parameters.queryItems).to(beEmpty())
            }
        }
    }
}
