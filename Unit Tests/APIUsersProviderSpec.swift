//
//  APIUsersProviderSpec.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

import Quick
import Nimble
import PromiseKit
import Mockingjay

@testable import Inbbbox

class APIUsersProviderSpec: QuickSpec {
    
    override func spec() {
        
        var sut: APIUsersProvider!
        var fetchedUser: UserType?
        
        beforeEach {
            sut = APIUsersProvider()
        }
        
        afterEach {
            sut = nil
        }
        
        describe("providing users") {
            
            beforeEach {
                self.stub(everything, json(self.fixtureJSON))
            }
            
            afterEach {
                self.removeAllStubs()
            }
            
            it("for id") {
                
                _ = sut.provideUser("fixture").then { user in
                    fetchedUser = user
                }
                
                expect(fetchedUser).toNotEventually(beNil())
            }
        }
    }
}

private extension APIUsersProviderSpec {
    
    var fixtureJSON: [String: AnyObject] {
        return JSONSpecLoader.sharedInstance.jsonWithResourceName("User").dictionaryObject! as [String : AnyObject]
    }
}

