//
//  UserFollowedByMeQuerySpec.swift
//  Inbbbox
//
//  Created by Peter Bruz on 15/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import Inbbbox

class UserFollowedByMeQuerySpec: QuickSpec {
    override func spec() {
        
        SharedQuerySpec.performSpecForQuery( { Void -> Query in
            return UserFollowedByMeQuery(user: User.fixtureUser())
            }) { Void -> QueryExpectation in
                return (method: .GET, encoding: .url, path: "/user/following/fixture.identifier")
        }
        
        describe("when newly initialized with user") {
            
            var sut: UserFollowedByMeQuery!
            
            beforeEach {
                sut = UserFollowedByMeQuery(user: User.fixtureUser())
            }
            
            afterEach {
                sut = nil
            }
            
            it("should have empty parameters") {
                expect(sut.parameters.queryItems).to(beEmpty())
            }
        }
    }
}
