//
//  ManagedBlockedUsersProviderSpec.swift
//  Inbbbox
//
//  Created by Robert Abramczyk on 06/03/2017.
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

import Quick
import Nimble
import CoreData
import PromiseKit

@testable import Inbbbox

class ManagedBlockedUsersProviderSpec: QuickSpec {

    override func spec() {
        var sut: ManagedBlockedUsersProvider!
        var inMemoryManagedObjectContext: NSManagedObjectContext!
        var user: User!

        beforeEach {
            inMemoryManagedObjectContext = setUpInMemoryManagedObjectContext()
            sut = ManagedBlockedUsersProvider(managedObjectContext: inMemoryManagedObjectContext)
        }

        afterEach {
            inMemoryManagedObjectContext = nil
            sut = nil
        }

        describe("Blocked users") {

            context("providing plocked users") {

                var blockedUsers: [UserType]?
                
                beforeEach {
                    user = User.fixtureUser()
                }

                it("all blocked users should be returned") {
                    let blockedUsersRequester = ManagedBlockedUsersRequester(managedObjectContext: inMemoryManagedObjectContext)

                    _ = firstly {
                        blockedUsersRequester.block(user: user)
                    }.then {
                        sut.provideBlockedUsers()
                    }.then { users -> Void in
                        blockedUsers = users
                    }
                    expect(blockedUsers?.count).toEventually(equal(1))
                }

            }
        }
    }
}
