//
//  ProfileViewModelSpec.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import PromiseKit
import Dobby

@testable import Inbbbox

class ProfileViewModelSpec: QuickSpec {

    override func spec() {

        var sut: ProfileViewModel!

        beforeEach {
            let connectionsRequesterMock = APIConnectionsRequesterMock()
    
            connectionsRequesterMock.isUserFollowedByMeStub.on(any()) { _ in
                return Promise<Bool>(value: true)
            }

            connectionsRequesterMock.followUserStub.on(any()) { _ in
                return Promise<Void>(value: Void())
            }

            connectionsRequesterMock.unfollowUserStub.on(any()) { _ in
                return Promise<Void>(value: Void())
            }
            
            sut = ProfileViewModel(user: User.fixtureUser())
            sut.connectionsRequester = connectionsRequesterMock
        }

        afterEach {
            sut = nil
        }

        describe("when newly initialized") {

            it("user should be correctly allocated") {
                expect(sut.user.identifier).to(equal(User.fixtureUser().identifier))
            }
        }

        describe("when checking if logged user follows an user") {

            it("should be correctly checked") {
                let promise = sut.isProfileFollowedByMe()
                
                expect(promise).to(resolveWithSuccess())
            }
        }

        describe("when following an user") {

            it("should be correctly followed") {
                let promise = sut.followProfile()
                
                expect(promise).to(resolveWithSuccess())
            }
        }

        describe("when unfollowing an user") {

            it("should be correctly unfollowed") {
                let promise = sut.unfollowProfile()
                
                expect(promise).to(resolveWithSuccess())
            }
        }
    }
}
