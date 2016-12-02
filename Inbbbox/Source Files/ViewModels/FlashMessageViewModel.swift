//
//  FlashMessageView.swift
//  Inbbbox
//
//  Created by Blazej Wdowikowski on 10/24/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

struct FlashMessageViewModel {
    /// title for message
    let title: String
    
    /// amount of time with which message will be displayed
    let duration: FlashMessageDuration
    
    /// Initializer of FlashMessageViewModel
    ///
    /// - parameter title: text that will be displayed in message
    /// - parameter duration: how long this message will be displayed. By default it's .Automatic
    init(title: String, duration: FlashMessageDuration = .automatic) {
        self.title = title
        self.duration = duration
    }
}
