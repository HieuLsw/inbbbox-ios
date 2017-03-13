//
//  FutureMatchers.swift
//  Inbbbox
//
//  Created by Krzysztof Kapitan on 10.03.2017.
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Quick
import Nimble
import PromiseKit

public func resolveWithError<T, E: Error>(type: E.Type, timeout: TimeInterval = 1.0) -> MatcherFunc<Promise<T>> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "resolve with error of type <\(type)>"
        
        guard let promise = try actualExpression.evaluate() else { return false }
        
        var resolvedError: Error?
        waitUntil(timeout: timeout) { done in
            promise
                .then { _ -> Void in
                    failureMessage.extendedMessage = "Instead it resolved with success"
                    done()
                }
                .catch { error in
                    resolvedError = error
                    done()
                }
        }
        
        return resolvedError.map { type(of: $0) == type } ?? false
    }
}

public func resolveWithSuccess<T>(timeout: TimeInterval = 1.0) -> MatcherFunc<Promise<T>> {
    return resolveWithValueMatching(timeout: timeout) { _ in }
}

public func resolveWithValueMatching<T>(timeout: TimeInterval = 1.0, _ expectations: @escaping (T) -> Void) -> MatcherFunc<Promise<T>> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "resolve with success"
        
        guard let promise = try actualExpression.evaluate() else { return false }
        
        var success: Bool = false
        waitUntil(timeout: timeout) { done in
            promise
                .then { value -> Void in
                    expectations(value)
                    success = true
                    done()
                }
                .catch { error in
                    failureMessage.extendedMessage = "Instead it resolved with error <\(error)>"
                    done()
            }
        }
        
        return success
    }
}
