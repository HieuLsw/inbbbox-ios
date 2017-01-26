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
        var connectionsRequesterMock: APIConnectionsRequesterMock!

        beforeEach {
            sut = ProfileViewModel(user: User.fixtureUser())
            connectionsRequesterMock = APIConnectionsRequesterMock()
            sut.connectionsRequester = connectionsRequesterMock
            connectionsRequesterMock.isUserFollowedByMeStub.on(any()) { _ in
                return Promise<Bool>(value: true)
            }

            connectionsRequesterMock.followUserStub.on(any()) { _ in
                return Promise<Void>(value: Void())
            }

            connectionsRequesterMock.unfollowUserStub.on(any()) { _ in
                return Promise<Void>(value: Void())
            }
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

            var didReceiveResponse: Bool?

            beforeEach {
                didReceiveResponse = false

                waitUntil { done in
                    sut.isProfileFollowedByMe().then { result -> Void in
                        didReceiveResponse = true
                        done()
                    }.catch { _ in fail("This should not be invoked") }
                }
            }

            afterEach {
                didReceiveResponse = nil
            }

            it("should be correctly checked") {
                expect(didReceiveResponse).to(beTruthy())
                expect(didReceiveResponse).toNot(beNil())
            }
        }

        describe("when following an user") {

            var didReceiveResponse: Bool?

            beforeEach {
                didReceiveResponse = false

                waitUntil { done in
                    sut.followProfile().then { result -> Void in
                        didReceiveResponse = true
                        done()
                    }.catch { _ in fail("This should not be invoked") }
                }
            }

            afterEach {
                didReceiveResponse = nil
            }

            it("should be correctly followed") {
                expect(didReceiveResponse).to(beTruthy())
                expect(didReceiveResponse).toNot(beNil())
            }
        }

        describe("when unfollowing an user") {

            var didReceiveResponse: Bool?

            beforeEach {
                didReceiveResponse = false

                waitUntil { done in
                    sut.unfollowProfile().then { result -> Void in
                        didReceiveResponse = true
                        done()
                    }.catch { _ in fail("This should not be invoked") }
                }
            }

            afterEach {
                didReceiveResponse = nil
            }

            it("should be correctly unfollowed") {
                expect(didReceiveResponse).to(beTruthy())
                expect(didReceiveResponse).toNot(beNil())
            }
        }
    }
}
