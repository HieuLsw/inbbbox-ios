//
//  PageRequestSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 03/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import Mockingjay

@testable import Inbbbox

class PageRequestSpec: QuickSpec {
    override func spec() {
        
        var sut: PageRequest!
        
        beforeEach {
            sut = PageRequest(query: QueryMock())
        }

        afterEach {
            sut = nil
            self.removeAllStubs()
        }
        
        context("when sending data with success") {

            beforeEach {
                self.stub(everything, json([]))
            }
            
            it("should respond") {
                let promise = sut.resume()
                
                expect(promise).to(resolveWithSuccess())
            }
        }

        context("when sending data with failure") {
    
            beforeEach {
                let error = NSError(domain: "fixture.domain", code: 0, userInfo: nil)
                self.stub(everything, failure(error))
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

private struct QueryMock: Query {
    let path = "/fixture/path"
    var parameters = Parameters(encoding: .json)
    let method = Method.POST
}
