//
//  MockLoginService.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 31/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

@testable import Inbbbox
import Foundation

struct MockLoginService: OAuthAuthorizable {
    
    let requestTokenURLString = "https://fixturerequest/requesttokenurl"
    let accessTokenURLString = "https://fixturerequest/accesstokenurl"
    let redirectURI = "https://redirecturi"
    let clientID = "fixture.clientID"
    let clientSecret = "fixture.clientSecret"
    let scope = "fixture.scope"
    
    func isRedirectionURL(_ url: URL?) -> Bool {
        let absoluteURL = (url!.scheme! + "://" + url!.host!)
        return absoluteURL == "http://mock.redirection.url"
    }
}

func ==(lhs: MockLoginService, rhs: OAuthAuthorizable) -> Bool {
    return (
        lhs.requestTokenURLString == rhs.requestTokenURLString &&
        lhs.accessTokenURLString == rhs.accessTokenURLString &&
        lhs.redirectURI == rhs.redirectURI &&
        lhs.clientID == rhs.clientID &&
        lhs.clientSecret == rhs.clientSecret &&
        lhs.scope == rhs.scope
    )
}
