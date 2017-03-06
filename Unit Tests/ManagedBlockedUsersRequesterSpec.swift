//
//  ManagedBlockedUsersRequesterSpec.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

import Quick
import Nimble
import CoreData
import PromiseKit

@testable import Inbbbox

class ManagedBlockedUsersRequesterSpec: QuickSpec {

    override func spec() {
        var sut: ManagedBlockedUsersRequester!
        var inMemoryManagedObjectContext: NSManagedObjectContext!
        var inMemoryManagedUserProvider: ManagedBlockedUsersProvider!
        var user: User!

        beforeEach {
            inMemoryManagedObjectContext = setUpInMemoryManagedObjectContext()
            sut = ManagedBlockedUsersRequester(managedObjectContext: inMemoryManagedObjectContext)
            inMemoryManagedUserProvider = ManagedBlockedUsersProvider(managedObjectContext: inMemoryManagedObjectContext)
        }

        afterEach {
            inMemoryManagedObjectContext = nil
            sut = nil
            inMemoryManagedUserProvider = nil
        }

        it("should have managed object context") {
            expect(sut.managedObjectContext).toNot(beNil())
        }

        describe("performing user block operations") {

            var blockedUsers: [UserType]?

            beforeEach {
                user = User.fixtureUser()
            }

            afterEach {
                blockedUsers = nil
            }

            context("blocking user") {

                it("user should be remembered as blocked") {
                    _ = firstly {
                        sut.block(user: user)
                    }.then {
                        inMemoryManagedUserProvider.provideBlockedUsers()
                    }.then { users -> Void in
                        blockedUsers = users
                    }
                    expect(blockedUsers?.count).toEventually(equal(1))
                    expect(blockedUsers?.first?.identifier).toEventually(equal(user.identifier))
                }

            }

            context("unblocking already blocked user") {

                beforeEach {
                    let managedUserEntity = NSEntityDescription.entity(forEntityName: ManagedBlockedUser.entityName, in: inMemoryManagedObjectContext)!
                    let managedBlockedUser = ManagedBlockedUser(entity: managedUserEntity, insertInto: inMemoryManagedObjectContext)
                    managedBlockedUser.mngd_identifier = user.identifier
                    managedBlockedUser.mngd_name = user.name
                    managedBlockedUser.mngd_username = user.username
                    managedBlockedUser.mngd_avatarURL = user.avatarURL?.absoluteString
                }

                it("user should be removed from blocked") {
                    _ = firstly {
                        sut.unblock(user: user)
                    }.then {
                        inMemoryManagedUserProvider.provideBlockedUsers()
                    }.then { users -> Void in
                        blockedUsers = users
                    }
                    expect(blockedUsers?.count).toEventually(equal(0))
                }

            }
        }
    }
}
