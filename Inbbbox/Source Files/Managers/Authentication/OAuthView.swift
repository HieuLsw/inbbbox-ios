//
//  OAuthView.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 21/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import WebKit

final class OAuthView: UIView {
    
    let webView: WKWebView
    
    override init(frame: CGRect) {
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = {
            let preferences = WKPreferences()
            preferences.javaScriptEnabled = false
            
            return preferences
        }()
        
        webView = WKWebView(frame: CGRectZero, configuration: configuration)
        webView.backgroundColor = .grayColor()
        
        super.init(frame: frame)
        
        addSubview(webView)
        backgroundColor = .whiteColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        webView.frame = bounds
    }

}
