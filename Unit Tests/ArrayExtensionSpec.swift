//
//  ArrayExtensionSpec.swift
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

class ArrayExtensionSpec: QuickSpec {
    
    override func spec() {

        describe("When using functions from extension") {
            context("unique values") {
                it("should return only unique values") {
                    let array = ["one", "two", "three", "four", "one", "two"]
                    expect(array.unique).to(haveCount(4))
                }
            }
            context("remove if contains") {
                it("should remove if exist") {
                    var array = ["one", "two", "three", "four"]
                    array.remove(ifContains: "two")
                    expect(array.unique).to(haveCount(3))
                }
                
                it("should not crash when trying to remove not existing object") {
                    var array = ["one", "two", "three", "four"]
                    array.remove(ifContains: "five")
                    expect(array.unique).to(haveCount(4))
                }
            }
        }
    }

}
