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
                
                var response: JSON?
                
                beforeEach {
                    let body = ["fixture.key": "fixture.value"]
                    self.stub(everything, json(body))
                }
                
                afterEach {
                    self.removeAllStubs()
                    response = nil
                }
                
                it("should respond with proper json") {
                    
                    waitUntil { done in
                        
                        sut.resume().then { _response -> Void in
                            response = _response
                            done()
                        }.catch { _ in fail() }
                    }
                    
                    expect(response).toNot(beNil())
                    expect(response?.dictionaryObject as? [String: String]).to(equal(["fixture.key": "fixture.value"]))
                }
            }
            
            context("when sending data with failure") {
                
                var error: Error?
                
                beforeEach {
                    let error = NSError(domain: "fixture.domain", code: 0, userInfo: nil)
                    self.stub(everything, failure(error))
                }
                
                afterEach {
                    error = nil
                    self.removeAllStubs()
                }
                
                it("should respond with proper json") {
                    
                    waitUntil { done in
                        
                        sut.resume().then { _ -> Void in
                            fail()
                        }.catch { _error in
                            error = _error
                            done()
                        }
                    }
                    
                    expect(error).toNot(beNil())
                    expect((error as! NSError).domain).to(equal("fixture.domain"))
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
