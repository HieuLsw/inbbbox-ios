//
//  Authenticator.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 21/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit
import WebKit
import SafariServices

class Authenticator {

    var networkService: OAuthAuthorizable?

    fileprivate let interactionHandler: ((SFSafariViewController) -> Void)
    fileprivate let success: ((Void) -> Void)
    fileprivate let failure: ((Error) -> Void)

    enum Service {
        case dribbble

        var instance: NetworkService {
            switch self {
                case .dribbble: return DribbbleNetworkService()
            }
        }
    }

    // MARK: Init

    init(service: Service,
         interactionHandler: @escaping ((SFSafariViewController) -> Void),
         success: @escaping (() -> Void),
         failure: @escaping ((Error) -> Void)) {
        self.networkService = service.instance as? OAuthAuthorizable
        self.interactionHandler = interactionHandler
        self.success = success
        self.failure = failure
    }

    // MARK: Public

    func login() {
        if let networkService = networkService {
            let controller = SFSafariViewController(url: networkService.requestTokenURLRequest().url!)
            controller.view.tintColor = .pinkColor()
            interactionHandler(controller)
        } else {
            self.failure(AuthenticatorError.requestTokenURLFailure)
        }
    }

    func loginWithOAuthURLCallback(_ url: URL) {
        login(url)
    }

    class func logout() {
        UserStorage.clearUser()
        TokenStorage.clear()
        APIRateLimitKeeper.sharedKeeper.clearRateLimitsInfo()
    }
}

// MARK: Private

private extension Authenticator {

    func login(_ url: URL) {
        firstly {
            decodeRequestTokenFromCallback(url)
        }.then { requestToken in
            self.gainAccessTokenWithRequestToken(requestToken)
        }.then { accessToken in
            self.persistToken(accessToken)
        }.then {
            self.fetchUser()
        }.then { user in
            self.persistUser(user)
        }.then { () -> Void in
            AnalyticsManager.trackLoginEvent(AnalyticsLoginEvent.loginSucceeded)
            self.success()
        }.catch { error in
            AnalyticsManager.trackLoginEvent(AnalyticsLoginEvent.loginFailed)
            self.failure(error)
        }
    }

    func decodeRequestTokenFromCallback(_ url: URL) -> Promise<String> {
        return Promise { fulfill, reject in
            var code: String?
            let components = url.query?.components(separatedBy: "&")
            if let components = components {
                for component in components {
                    if component.range(of: "code=") != nil {
                        code = component.components(separatedBy: "=").last
                    }
                }
                code != nil ? fulfill(code!) : reject(AuthenticatorError.authTokenMissing as Error)
            } else {
                reject(AuthenticatorError.authTokenMissing as Error)
            }
        }
    }

    func gainAccessTokenWithRequestToken(_ token: String) -> Promise<String> {
        return Promise<String> { fulfill, reject in

            guard let request = self.networkService?.accessTokenURLRequestWithRequestToken(token) else {
                return reject(AuthenticatorError.authTokenMissing as Error)
            }

            firstly {
                return URLSession.shared.dataTask(with: request)
            }.then { data -> Void in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any> else {
                    throw AuthenticatorError.dataDecodingFailure
                }

                guard let accessToken = json?["access_token"] as? String else {
                    throw AuthenticatorError.accessTokenMissing
                }
                fulfill(accessToken)

            }.catch { error in
                reject(error)
            }
        }
    }

    func fetchUser() -> Promise<User> {
        return Promise<User> { fulfill, reject in

            let query = UserQuery()
            let request = Request(query: query)

            firstly {
                request.resume()
            }.then { json -> Void in
                guard let json = json else {
                    throw AuthenticatorError.unableToFetchUser
                }
                fulfill(User.map(json))

            }.catch { error in
                reject(error)
            }
        }
    }

    func persistToken(_ token: String) {
        TokenStorage.storeToken(token)
    }

    func persistUser(_ user: User) {
        UserStorage.storeUser(user)
        UserStorage.clearGuestUser()
    }
}
