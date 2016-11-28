//
//  OAuthAuthorizableSpec.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 30/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble

@testable import Inbbbox

class OAuthAuthorizableSpec: QuickSpec {
    
    fileprivate struct MockOAuthAuthorizableService : OAuthAuthorizable {
        
        let requestTokenURLString = "https://fixturerequest/requesttokenurl"
        let accessTokenURLString = "https://fixturerequest/accesstokenurl"
        let redirectURI = "https://redirecturi"
        let clientID = "fixture.clientID"
        let clientSecret = "fixture.clientSecret"
        let scope = "fixture.scope"
    }

    override func spec() {
        
        var sut: MockOAuthAuthorizableService?
        
        beforeEach {
            sut = MockOAuthAuthorizableService()
        }
        
        afterEach {
            sut = nil
        }
        
        describe("when creating request token url request") {
            
            var requestTokenURLRequest: URLRequest!
            
            beforeEach {
                requestTokenURLRequest = sut?.requestTokenURLRequest()
            }
            
            it("should have proper url") {
                let absoluteString = {
                    "https://fixturerequest/requesttokenurl" +
                    "?" +
                    "scope=fixture.scope" +
                    "&" +
                    "redirect_uri=https://redirecturi" +
                    "&" +
                    "client_id=fixture.clientID"
                }()
                expect(requestTokenURLRequest.url?.absoluteString).to(equal(absoluteString))
            }
            
            it("should use GET method") {
                expect(requestTokenURLRequest.httpMethod).to(equal("GET"))
            }
        }
        
        describe("when creating access token url request") {
            
            var accessTokenURLRequest: URLRequest!
            
            beforeEach {
                accessTokenURLRequest = sut?.accessTokenURLRequestWithRequestToken("fixture.request.token")
            }

            it("should use POST method") {
                expect(accessTokenURLRequest.httpMethod).to(equal("POST"))
            }
        }
        
        describe("when checking redirection url") {
            
            var isRedirectionURL: Bool!
            
            describe("with wrong url") {
                
                beforeEach {
                    let url = URL(string: "https://wrongredirecturi")
                    isRedirectionURL = sut?.isRedirectionURL(url)
                }
                
                it("shouldn't be marked redirected") {
                    expect(isRedirectionURL).to(beFalsy())
                }
            }
            
            describe("with correct url") {
                
                beforeEach {
                    let url = URL(string: "https://redirecturi")
                    isRedirectionURL = sut?.isRedirectionURL(url)
                }
                
                it("should be marked as redirected") {
                    expect(isRedirectionURL).to(beTruthy())
                }
            }
        }
        
        describe("when checking silent authentication url") {
            
            var isSilentAuthenticationURL: Bool!
            
            describe("with wrong url") {
                
                beforeEach {
                    let url = URL(string: "https://anyurl/")
                    isSilentAuthenticationURL = sut?.isSilentAuthenticationURL(url)
                }
                
                it("should be marked as silent") {
                    expect(isSilentAuthenticationURL).to(beTruthy())
                }
            }
            
            describe("with correct url") {
                
                beforeEach {
                    let url = URL(string: "https://anyurl/login?")
                    isSilentAuthenticationURL = sut?.isSilentAuthenticationURL(url)
                }
                
                it("shouldn't be marked as silent") {
                    expect(isSilentAuthenticationURL).to(beFalsy())
                }
            }
        }
    }
}
