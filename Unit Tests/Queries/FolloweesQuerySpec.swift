//
//  FolloweesQuerySpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 26/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import SwiftyJSON

@testable import Inbbbox

class FolloweesQuerySpec: QuickSpec {
    override func spec() {
        
        var sut: FolloweesQuery!
        
        afterEach {
            sut = nil
        }
        
        describe("when newly initialize") {
            
            SharedQuerySpec.performSpecForQuery( { Void -> Query in
                return FolloweesQuery()
            }) { Void -> QueryExpectation in
                return (method: .GET, encoding: .url, path: "/user/following")
            }
            
            beforeEach {
                sut = FolloweesQuery()
            }
            
            it("should have empty parameters") {
                expect(sut.parameters.queryItems).to(beEmpty())
            }
        }
        
        describe("when newly initialize with user") {
            
            SharedQuerySpec.performSpecForQuery( { Void -> Query in
                return FolloweesQuery(followeesOfUser: self.fixtureUser)
            }) { Void -> QueryExpectation in
                return (method: .GET, encoding: .url, path: "/users/fixture.username/following")
            }
            
            beforeEach {
                sut = FolloweesQuery(followeesOfUser: self.fixtureUser)
            }
            
            it("should have empty parameters") {
                expect(sut.parameters.queryItems).to(beEmpty())
            }
        }
    }
}

private extension FolloweesQuerySpec {
    
    var fixtureUser: User {
        
        let dictionary = [
            "id" : "fixture.id",
            "name" : "fixture.name",
            "username" : "fixture.username",
            "avatar_url" : "fixture.avatar.url"
        ]
        return User(json: JSON(dictionary))
    }
}
