//
//  CreateBucketQuerySpec.swift
//  Inbbbox
//
//  Created by Peter Bruz on 09/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import Inbbbox

class CreateBucketQuerySpec: QuickSpec {
    override func spec() {
        
        SharedQuerySpec.performSpecForQuery( { Void -> Query in
            return CreateBucketQuery(name: "fixture.name", description: nil)
        }) { Void -> QueryExpectation in
                return (method: .POST, encoding: .json, path: "/buckets")
        }
        
        describe("when newly initialized with bucket") {
            
            var sut: CreateBucketQuery!
            
            beforeEach {
                sut = CreateBucketQuery(name: "fixture.name", description: nil)
            }
            
            afterEach {
                sut = nil
            }
            
            it("should have empty parameters") {
                expect(sut.parameters.queryItems).to(beEmpty())
            }
            
            it("should have name parameter properly set") {
                expect(sut.parameters["name"] as? String).to(equal("fixture.name"))
            }
            
            it("should have no description parameter") {
                expect(sut.parameters["description"]).to(beNil())
            }
        }
    }
}
