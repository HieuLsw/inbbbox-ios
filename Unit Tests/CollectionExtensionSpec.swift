//
//  CollectionExtensionSpec.swift
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

class CollectionExtensionSpec: QuickSpec {
    
    override func spec() {
        
        describe("When using functions from extension") {
            context("shuffling function") {
                it("should return shuffled version of array") {
                    let array = ["one", "two", "three", "four", "one", "two"]
                    let shuffled = array.shuffle()
                    var differentCount = 0
                    expect(shuffled).to(haveCount(6))
                    for (index, item) in array.enumerated() {
                        if item != shuffled[index] {
                            differentCount += 1
                        }
                        expect(shuffled).to(contain(item))
                    }
                    expect(differentCount).toNot(equal(0))
                }
            }
        }
    }
}
