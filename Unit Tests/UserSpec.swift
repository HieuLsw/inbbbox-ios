//
//  UserSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 05/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import SwiftyJSON

@testable import Inbbbox

class UserSpec: QuickSpec {
    override func spec() {
        
        it("should support secure coding") {
            expect(User.supportsSecureCoding).to(beTruthy())
        }
        
        var sut: User!
        
        afterEach {
            sut = nil
        }
        
        describe("when mapping user") {
            
            beforeEach {
                sut = User.fixtureUser()
            }
            
            it("user should exist") {
                expect(sut).toNot(beNil())
            }
            
            it("user's username should be properly mapped") {
                expect(sut.username).to(equal("fixture.username"))
            }
            
            it("user's name should be properly mapped") {
                expect(sut.name).to(equal("fixture.name"))
            }
            
            it("user's avatar url should be properly mapped") {
                expect(sut.avatarURL).to(equal(URL(string: "fixture.avatar.url")))
            }
            
            it("user's id should be properly mapped") {
                expect(sut.identifier).to(equal("fixture.identifier"))
            }
            
            it("user's shots count should be properly mapped") {
                expect(sut.shotsCount).to(equal(1))
            }
        }
        
        describe("when encoding user") {
            
            var data: Data!
            
            beforeEach {
                sut = User.fixtureUser()
                data = NSKeyedArchiver.archivedData(withRootObject: sut)
            }
            
            it("data should not be nil") {
                expect(data).toNot(beNil())
            }
            
            context("and decoding data") {
                
                var decodedUser: User?
                
                beforeEach {
                    decodedUser = NSKeyedUnarchiver.unarchiveObject(with: data) as? User
                }
                
                it("user should not be nil") {
                    expect(decodedUser).toNot(beNil())
                }
                
                it("user's username should be properly decoded") {
                    expect(sut.username).to(equal(decodedUser!.username))
                }
                
                it("user's name should be properly decoded") {
                    expect(sut.name).to(equal(decodedUser!.name))
                }
                
                it("user's avatar url should be properly decoded") {
                    expect(sut.avatarURL).to(equal(decodedUser!.avatarURL))
                }
                
                it("user's id should be properly decoded") {
                    expect(sut.identifier).to(equal(decodedUser!.identifier))
                }
                
                it("user's shots count should be properly mapped") {
                    expect(sut.shotsCount).to(equal(1))
                }
            }
        }
    }
}
