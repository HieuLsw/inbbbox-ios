//
//  RemoveFromBucketQuerySpec.swift
//  Inbbbox
//
//  Created by Peter Bruz on 08/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class RemoveFromBucketQuerySpec: QuickSpec {
    override func spec() {
        
        SharedQuerySpec.performSpecForQuery( { Void -> Query in
            return RemoveFromBucketQuery(shot: Shot.fixtureShot(), bucket: Bucket.fixtureBucket())
        }) { Void -> QueryExpectation in
            return (method: .DELETE, encoding: .json, path: "/buckets/fixture.identifier/shots")
        }
        
        describe("when newly initialized with shot and bucket identifiers") {
            
            var sut: RemoveFromBucketQuery!
            
            beforeEach {
                sut = RemoveFromBucketQuery(shot: Shot.fixtureShot(), bucket: Bucket.fixtureBucket())
            }
            
            afterEach {
                sut = nil
            }
            
            it("should have one parameter - shot_id") {
                expect(sut.parameters.body).to(equal(try! JSONSerialization.data(withJSONObject: ["shot_id": "fixture.identifier"], options: .prettyPrinted)))
            }
        }
    }
}
