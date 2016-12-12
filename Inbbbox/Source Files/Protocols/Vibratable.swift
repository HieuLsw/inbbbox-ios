//
//  Vibratable.swift
//  Inbbbox
//
//  Created by Dawid Markowski on 08.12.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

protocol Vibratable {
    func vibrate(feedbackType feedbackType: UINotificationFeedbackType)
}

extension Vibratable {
    func vibrate(feedbackType feedbackType: UINotificationFeedbackType) {
        if #available(iOS 10.0, *) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(feedbackType)
        }
    }
}
