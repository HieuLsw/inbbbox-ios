//
//  HTMLTranslatorSpec.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class HTMLTranslatorSpec: QuickSpec {
    override func spec() {

        describe("when providing text with HTML tags") {

            let exampleHTML = "This is <b>really</b> <i>cool</i> shot!"
            let result = HTMLTranslator.translateToDribbbleHTML(text: exampleHTML)

            it("should not contain <b> tag") {
                expect(result.range(of: "<b>")).to(beNil())
            }

            it("should contain <strong> tag") {
                expect(result.range(of: "<strong>")).toNot(beNil())
            }

            it("should not contain </b> tag") {
                expect(result.range(of: "</b>")).to(beNil())
            }

            it("should contain </strong> tag") {
                expect(result.range(of: "</strong>")).toNot(beNil())
            }

            it("should not contain <i> tag") {
                expect(result.range(of: "<i>")).to(beNil())
            }

            it("should contain <em> tag") {
                expect(result.range(of: "<em>")).toNot(beNil())
            }

            it("should not contain </i> tag") {
                expect(result.range(of: "</i>")).to(beNil())
            }

            it("should contain </em> tag") {
                expect(result.range(of: "</em>")).toNot(beNil())
            }

            it("should insert tag in proper place") {
                let bRange = exampleHTML.range(of: "<b>")
                let strongRange = result.range(of: "<strong>")

                expect(bRange!.lowerBound == strongRange!.lowerBound).to(beTrue())
            }
        }

        describe("when providing text without HTML tags") {

            let exampleHTML = "This is really cool shot!"
            let result = HTMLTranslator.translateToDribbbleHTML(text: exampleHTML)

            it("should not modify original text") {
                expect(result == exampleHTML).to(beTrue())
            }
        }
    }
}
