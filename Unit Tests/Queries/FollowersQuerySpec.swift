//
//  FollowersQuerySpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 26/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import SwiftyJSON

@testable import Inbbbox

class FollowersQuerySpec: QuickSpec {
    override func spec() {
        
        var sut: FollowersQuery!
        
        afterEach {
            sut = nil
        }
        
        describe("when newly initialize") {
            
            SharedQuerySpec.performSpecForQuery( { Void -> Query in
                return FollowersQuery()
            }) { Void -> QueryExpectation in
                return (method: .GET, encoding: .url, path: "/user/followers")
            }
            
            beforeEach {
                sut = FollowersQuery()
            }
            
            it("should have empty parameters") {
                expect(sut.parameters.queryItems).to(beEmpty())
            }
        }
        
        describe("when newly initialize with user") {
            
            SharedQuerySpec.performSpecForQuery( { Void -> Query in
                return FollowersQuery(followersOfUser: self.fixtureUser)
            }) { Void -> QueryExpectation in
                return (method: .GET, encoding: .url, path: "/users/fixture.username/followers")
            }
            
            beforeEach {
                sut = FollowersQuery(followersOfUser: self.fixtureUser)
            }
            
            it("should have empty parameters") {
                expect(sut.parameters.queryItems).to(beEmpty())
            }
        }
    }
}

private extension FollowersQuerySpec {
    
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
