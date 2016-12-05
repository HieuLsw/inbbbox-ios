//
//  OnboardingSkipButtonAnimator.swift
//  Inbbbox
//
//  Created by Blazej Wdowikowski on 11/25/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class OnboardingSkipButtonAnimator {
    
    var buttonHidden: Bool {
        return view.skipButton.hidden
    }
    private let view: ShotsCollectionBackgroundView
    private let animationDuration: NSTimeInterval
    
    init(view: ShotsCollectionBackgroundView, animationDuration: NSTimeInterval = 1.0) {
        self.view = view
        self.animationDuration = animationDuration
    }

    func showButton() {
        guard buttonHidden else { return }
        startFadeInAnimation()
    }
    
    func hideButton() {
        guard !buttonHidden else { return }
        startFadeOutAnimation()
    }
    
}

private extension OnboardingSkipButtonAnimator {
    
    func startFadeInAnimation() {
        let button = view.skipButton
        button.hidden = false
        
        UIView.animate(duration: animationDuration, delay: 0, options: [.BeginFromCurrentState]) { 
            button.alpha = 1
        }
    }
    
    func startFadeOutAnimation() {
        let button = view.skipButton
        
        UIView.animateWithDuration(animationDuration, delay: 0, options: [.BeginFromCurrentState], animations: { 
            button.alpha = 0
        }) { _ in
            button.hidden = true
        }
    }
}
