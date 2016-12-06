//
//  OnboardingSkipable.swift
//  Inbbbox
//
//  Created by Blazej Wdowikowski on 11/25/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

protocol OnboardingSkipButtonHandlerDelegate: class {
    // Called when skipButton should appear on certain situations
    func shouldSkipButtonAppear()
    // Called when skipButton should disappear on certain situations
    func shouldSkipButtonDisappear()
}
