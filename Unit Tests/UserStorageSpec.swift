//
//  UserStorageSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 05/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import SwiftyJSON

@testable import Inbbbox

class UserStorageSpec: QuickSpec {
    override func spec() {
        
        var savedUserBeforeTestLaunch: User?
        
        beforeSuite {
            savedUserBeforeTestLaunch = UserStorage.currentUser
        }
        
        afterSuite {
            if let user = savedUserBeforeTestLaunch {
                UserStorage.storeUser(user)
            }
        }
        
        beforeEach {
            UserStorage.clearUser()
        }
        
        describe("when storing user") {
            
            beforeEach {
                UserStorage.storeUser(User.fixtureUser())
            }
            
            it("user should be properly stored") {
                expect(UserStorage.currentUser).toNot(beNil())
            }
            
            it("loggedIn flag should be true") {
                expect(UserStorage.isUserSignedIn).to(beTruthy())
            }
            
            it("user's username should be same as previously stored") {
                expect(UserStorage.currentUser!.username).to(equal("fixture.username"))
            }
            
            it("user's name should be same as previously stored") {
                expect(UserStorage.currentUser!.name).to(equal("fixture.name"))
            }
            
            it("user's avatar url should be same as previously stored") {
                expect(UserStorage.currentUser!.avatarURL).to(equal(URL(string:"fixture.avatar.url")))
            }
            
            it("user's id should be same as previously stored") {
                expect(UserStorage.currentUser!.identifier).to(equal("fixture.identifier"))
            }
            
            it("user's shots count should be same as previously stored") {
                expect(UserStorage.currentUser!.shotsCount).to(equal(1))
            }
            
            context("and clearing storage") {
                
                beforeEach {
                    UserStorage.clearUser()
                }
                
                it("user should be nil") {
                    expect(UserStorage.currentUser).to(beNil())
                }
                
                it("loggedIn flag should be false") {
                    expect(UserStorage.isUserSignedIn).to(beFalsy())
                }
            }
        }
    }
}
