//
//  RequestSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 03/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import Mockingjay
import SwiftyJSON

@testable import Inbbbox

class RequestSpec: QuickSpec {
    override func spec() {
        
        var sut: Request!
        
        describe("when initializing with query") {
            
            beforeEach {
                sut = Request(query: QueryMock())
            }
            
            afterEach {
                sut = nil
            }
            
            it("request should have properly assigned query") {
                expect(sut.query.path).to(equal("/fixture/path"))
            }
            
            it("should use NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData") {
                expect(sut.session.configuration.requestCachePolicy == NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData).to(beTruthy())
            }

            context("when sending data with success") {
                
                beforeEach {
                    let body = ["fixture.key": "fixture.value"]
                    self.stub(everything, json(body))
                }
                
                afterEach {
                    self.removeAllStubs()
                }
                
                it("should respond with proper json") {
                    let promise = sut.resume()
                    
                    expect(promise).to(resolveWithValueMatching { (response: JSON?) in
                        let dictionary = response?.dictionaryObject as? [String: String]
                        
                        expect(dictionary).toNot(beNil())
                        expect(dictionary).to(equal(["fixture.key": "fixture.value"]))
                    })
                }
            }
            
            context("when sending data with failure") {
                
                beforeEach {
                    let error = NSError(domain: "fixture.domain", code: 0, userInfo: nil)
                    self.stub(everything, failure(error))
                }
                
                afterEach {
                    self.removeAllStubs()
                }
                
                it("should respond with proper json") {
                    let promise = sut.resume()
                    
                    expect(promise).to(resolveWithErrorMatching { error in
                        let nsError = error as NSError
                        expect(nsError.domain).to(equal("fixture.domain"))
                    })
                }
            }
        }
    }
}

private struct QueryMock: Query {
    let path = "/fixture/path"
    var parameters = Parameters(encoding: .json)
    let method = Method.POST
}
