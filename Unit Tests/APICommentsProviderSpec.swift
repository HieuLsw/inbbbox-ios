//
//  APICommentsProviderSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 10/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import PromiseKit
import Dobby

@testable import Inbbbox

class APICommentsProviderSpec: QuickSpec {
    override func spec() {
        
        var sut: APICommentsProviderPrivateMock!
        
        beforeEach {
            sut = APICommentsProviderPrivateMock()
        }
        
        afterEach {
            sut = nil
        }
        
        describe("when providing comments for shot") {
            
            it("comments should be properly returned") {
                let promise = sut.provideCommentsForShot(Shot.fixtureShot())
                
                expect(promise).to(resolveWithValueMatching { comments in
                    expect(comments).toNot(beNil())
                    expect(comments).to(haveCount(3))
                })
            }
        }
        
        describe("when providing comments from next page") {
            
            it("comments should be properly returned") {
                let promise = sut.nextPage()
                
                expect(promise).to(resolveWithValueMatching { comments in
                    expect(comments).toNot(beNil())
                    expect(comments).to(haveCount(3))
                })
            }
        }
        
        describe("when providing comments from previous page") {
            
            it("comments should be properly returned") {
                let promise = sut.previousPage()
                
                expect(promise).to(resolveWithValueMatching { comments in
                    expect(comments).toNot(beNil())
                    expect(comments).to(haveCount(3))
                })
            }
        }
    }
}

//Explanation: Create APICommentsProviderPrivateMock to override methods from PageableProvider.
private class APICommentsProviderPrivateMock: APICommentsProvider {

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

            let json = JSONSpecLoader.sharedInstance.fixtureCommentsJSON(withCount: 3)
            let result = json.map { T.map($0) }

            fulfill(result)
        }
    }
}
