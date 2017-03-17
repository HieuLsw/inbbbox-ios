//
//  ManagedBlockedUsersProviderSpec.swift
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
            var blockedUsersRequester: ManagedBlockedUsersRequester!
            
            context("providing blocked users") {

                beforeEach {
                    user = User.fixtureUser()
                    blockedUsersRequester = ManagedBlockedUsersRequester(managedObjectContext: inMemoryManagedObjectContext)

                }

                it("all blocked users should be returned") {
                    let promise = firstly {
                        blockedUsersRequester.block(user: user)
                    }.then {
                        sut.provideBlockedUsers()
                    }
                    
                    expect(promise).to(resolveWithValueMatching { blockedUsers in
                        expect(blockedUsers).to(haveCount(1))
                    })
                }
            }
        }
    }
}
