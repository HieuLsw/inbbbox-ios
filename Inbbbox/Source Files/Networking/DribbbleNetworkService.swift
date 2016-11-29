//
//  DribbbleNetworkService.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 14/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct DribbbleNetworkService: SecureNetworkService, HeaderAuthorizable, OAuthAuthorizable {

    // MARK: SecureNetworkService

    /// Host for Dribbble service.
    let host = Dribbble.Host
    /// API version for Dribbble service.
    let version = Dribbble.APIVersion

    // MARK: OAuthAuthorizable

    /// URL string for request token for Dribbble service.
    let requestTokenURLString = Dribbble.RequestTokenURLString
    /// URL string for access token for Dribbble service.
    let accessTokenURLString = Dribbble.AccessTokenURLString
    /// Redirect URL string for Dribbble service.
    let redirectURI = Dribbble.CallbackURLString
    /// Client ID for Dribbble service.
    let clientID = Dribbble.ClientID
    /// Client secret ID for Dribbble service.
    let clientSecret = Dribbble.ClientSecret
    /// Scope for Dribbble service.
    let scope = Dribbble.Scope

    /// Authorize given request.
    ///
    /// - parameter request: Request to authorize.
    func authorizeRequest(_ request: NSMutableURLRequest) {

        let token = TokenStorage.currentToken ?? Dribbble.ClientAccessToken
        let header = authorizationHeader(token)
        request.setHeader(header)
    }
}

extension NSMutableURLRequest {
    func setHeader(_ header: HTTPHeader) {
        setValue(header.value, forHTTPHeaderField: header.name)
    }
}
