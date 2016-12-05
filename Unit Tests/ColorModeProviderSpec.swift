//
//  ColorModeProviderSpec.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 27.10.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class ColorModeProviderSpec: QuickSpec {

    override func spec() {

        describe("when changing mode to NightMode") {

            ColorModeProvider.change(to: .NightMode)

            it("should return NightMode as current") {
                let current = ColorModeProvider.current()
                expect(current == NightMode()).to(beTruthy())
            }

            it("should save NightMode to Settings") {
                let current = Settings.Customization.CurrentColorMode
                expect(current.rawValue == ColorMode.NightMode.rawValue).to(beTruthy())
            }
        }
    }
}
