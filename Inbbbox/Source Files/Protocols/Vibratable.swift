//
//  Vibratable.swift
//  Inbbbox
//
//  Created by Dawid Markowski on 08.12.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

protocol Vibratable {
    func vibrate(with type: UINotificationFeedbackType)
}

extension Vibratable {
    func vibrate(with type: UINotificationFeedbackType) {
        if #available(iOS 10.0, *) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(type)
        }
    }
}
