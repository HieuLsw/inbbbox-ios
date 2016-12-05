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
        return view.skipButton.isHidden
    }
    fileprivate let view: ShotsCollectionBackgroundView
    fileprivate let animationDuration: TimeInterval
    
    init(view: ShotsCollectionBackgroundView, animationDuration: TimeInterval = 1.0) {
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

fileprivate extension OnboardingSkipButtonAnimator {
    
    func startFadeInAnimation() {
        let button = view.skipButton
        button.isHidden = false

        UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState], animations: { 
            button.alpha = 1
        }, completion: nil)
    }
    
    func startFadeOutAnimation() {
        let button = view.skipButton
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState], animations: { 
            button.alpha = 0
        }) { _ in
            button.isHidden = true
        }
    }
}
