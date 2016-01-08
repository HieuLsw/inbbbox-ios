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
            UserStorage.clear()
        }
        
        describe("when storing user") {
            
            beforeEach {
                UserStorage.storeUser(self.fixtureUser)
            }
            
            it("user should be properly stored") {
                expect(UserStorage.currentUser).toNot(beNil())
            }
            
            it("user's username should be same as previously stored") {
                expect(UserStorage.currentUser!.username).to(equal("fixture.username"))
            }
            
            it("user's name should be same as previously stored") {
                expect(UserStorage.currentUser!.name).to(equal("fixture.name"))
            }
            
            it("user's avatar url should be same as previously stored") {
                expect(UserStorage.currentUser!.avatarString).to(equal("fixture.avatar.url"))
            }
            
            it("user's id should be same as previously stored") {
                expect(UserStorage.currentUser!.identifier).to(equal("fixture.id"))
            }
            
            context("and clearing storage") {
                
                beforeEach {
                    UserStorage.clear()
                }
                
                it("user should be nil") {
                    expect(UserStorage.currentUser).to(beNil())
                }
            }
        }
    }
}

private extension UserStorageSpec {
    
    var fixtureUser: User {
        
        let dictionary = [
                "id" : "fixture.id",
                "name" : "fixture.name",
                "username" : "fixture.username",
                "avatar_url" : "fixture.avatar.url"
            ]
        return User(json: JSON(dictionary))
    }
}