//
//  Vibratable.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

protocol Vibratable {
    func vibrate(feedbackType: UINotificationFeedbackType)
}

extension Vibratable {
    func vibrate(feedbackType: UINotificationFeedbackType) {
        if #available(iOS 10.0, *) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(feedbackType)
        }
    }
}
