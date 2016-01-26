//
//  NSAttributedStringExtensionSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 26/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Nimble
import Quick
@testable import Inbbbox

class NSAttributedStringExtensionSpec: QuickSpec {
    
    override func spec() {
        
        var sut: NSAttributedString!
        
        beforeEach {
            sut = nil
        }
        
        describe("when init with nil") {
            
            beforeEach {
                sut = NSAttributedString(htmlString: nil)
            }
            
            it("should be nil") {
                expect(sut).to(beNil())
            }
        }
        
        describe("when init with common string") {
            
            beforeEach {
                sut = NSAttributedString(htmlString: "fixture.string")
            }
            
            it("attributed string should be properly constructed") {
                expect(sut.string).to(equal("fixture.string"))
            }
        }
        
        
        describe("when init with common string") {
            
            beforeEach {
                sut = NSAttributedString(htmlString: "<b>fixture.string</b>")
            }
            
            it("attributed string should be properly constructed") {
                expect(String(sut).rangeOfString("font-weight: bold")).toNot(beNil())
            }
        }
    }
}
