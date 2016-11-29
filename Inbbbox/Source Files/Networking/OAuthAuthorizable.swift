//
//  OAuthAuthorizable.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 18/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

protocol OAuthAuthorizable {

    var requestTokenURLString: String { get }
    var accessTokenURLString: String { get }

    var clientID: String { get }
    var clientSecret: String { get }
    var redirectURI: String { get }
    var scope: String { get }

    /// Provide `NSURLRequest` that should be used to receive token from API.
    ///
    /// - returns: Request needed to get token.
    func requestTokenURLRequest() -> URLRequest

    /// Provide `NSURLRequest` that should be used to receive access token from API based on request token.
    ///
    /// - parameter token: Request token.
    ///
    /// - returns: Request needed to get access token.
    func accessTokenURLRequestWithRequestToken(_ token: String) -> URLRequest

    /// Check if URL is redirection URL.
    ///
    /// - parameter url: URL to check.
    ///
    /// - returns: `true` if given URL is redirection URL, `false` otherwise.
    func isRedirectionURL(_ url: URL?) -> Bool

    /// Check if URL is silent authentication URL.
    ///
    /// - parameter url: URL to check.
    ///
    /// - returns: `true` if given URL is silent authentication URL, `false` otherwise.
    func isSilentAuthenticationURL(_ url: URL?) -> Bool
}

extension OAuthAuthorizable {

    func requestTokenURLRequest() -> URLRequest {

        var parameters = Parameters(encoding: .url)
        parameters["client_id"] = clientID as AnyObject?
        parameters["redirect_uri"] = redirectURI as AnyObject?
        parameters["scope"] = scope as AnyObject?

        return requestForURLString(requestTokenURLString, HTTPMethod: .GET, parameters: parameters)
    }

    func accessTokenURLRequestWithRequestToken(_ token: String) -> URLRequest {

        var parameters = Parameters(encoding: .url)
        parameters["client_id"] = clientID as AnyObject?
        parameters["client_secret"] = clientSecret as AnyObject?
        parameters["redirect_uri"] = redirectURI as AnyObject?
        parameters["code"] = token as AnyObject?

        return requestForURLString(accessTokenURLString, HTTPMethod: .POST, parameters: parameters)
    }

    func isRedirectionURL(_ url: URL?) -> Bool {

        if let url = url, let host = url.host {
            return redirectURI == (url.scheme! + "://" + host)
        }
        return false
    }

    func isSilentAuthenticationURL(_ url: URL?) -> Bool {
        return !(url != nil && url!.absoluteString.contains("login?"))
    }
}

private extension OAuthAuthorizable {

    func requestForURLString(_ url: String, HTTPMethod: Method, parameters: Parameters) -> URLRequest {

        var components = URLComponents(string: url)
        components?.queryItems = parameters.queryItems as [URLQueryItem]?

        let mutableRequest = NSMutableURLRequest(url: components!.url!)
        mutableRequest.httpMethod = HTTPMethod.rawValue

        guard let immutableRequest = mutableRequest.copy() as? URLRequest else {
            return URLRequest(url: components!.url!)
        }
        return immutableRequest
    }
}
