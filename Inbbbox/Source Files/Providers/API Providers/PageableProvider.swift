//
//  PageableProvider.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 04/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON

enum PageableProviderError: Error {
    case behaviourUndefined
    case didReachLastPage
    case didReachFirstPage
}

class PageableProvider: Verifiable {

    fileprivate(set) var page = UInt(1)
    fileprivate(set) var pagination = UInt(30)

    fileprivate var nextPageableComponents: [PageableComponent]?
    fileprivate var previousPageableComponents: [PageableComponent]?

    fileprivate var serializationKey: String?
    fileprivate var didDefineProviderMethodBefore = false

     /**
     Initializer with customizable parameters.

     - parameter page:          Number of page from which ShotsProvider should start to provide shots.
     - parameter pagination:    Pagination of request.
     */
    init(page: UInt, pagination: UInt) {
        self.page = page
        self.pagination = pagination
    }

    /**
     Default initializer provided for simplify initalization with default parameters.
     Required by subclasses.
     */
    init() {}

    func firstPageForQueries<T: Mappable>(_ queries: [Query], withSerializationKey key: String?) -> Promise<[T]?> {
        return Promise<[T]?> { fulfill, reject in

            resetPages()
            serializationKey = key
            didDefineProviderMethodBefore = true

            let mappedQueries = queries.map { queryByPagingConfiguration($0) }

            pageWithQueries(mappedQueries).then(execute: fulfill).catch(execute: reject)
        }
    }

    func nextPageFor<T: Mappable>(_ type: T.Type) -> Promise<[T]?> {
        return Promise<[T]?> { fulfill, reject in

            if !didDefineProviderMethodBefore {
                throw PageableProviderError.behaviourUndefined
            }

            guard let nextPageableComponents = nextPageableComponents else {
                throw PageableProviderError.didReachLastPage
            }

            let queries = nextPageableComponents.map {
                PageableQuery(path: $0.path, queryItems: $0.queryItems)
            } as [Query]

            pageWithQueries(queries).then(execute: fulfill).catch(execute: reject)
        }
    }

    func previousPageFor<T: Mappable>(_ type: T.Type) -> Promise<[T]?> {
        return Promise<[T]?> { fulfill, reject in

            if !didDefineProviderMethodBefore {
                throw PageableProviderError.behaviourUndefined
            }

            guard let previousPageableComponents = previousPageableComponents else {
                throw PageableProviderError.didReachFirstPage
            }

            let queries = previousPageableComponents.map {
                PageableQuery(path: $0.path, queryItems: $0.queryItems)
            } as [Query]

            pageWithQueries(queries).then(execute: fulfill).catch(execute: reject)
        }
    }

    func resetPages() {
        serializationKey = nil
        nextPageableComponents = nil
        previousPageableComponents = nil
    }
}

private extension PageableProvider {

    func pageWithQueries<T: Mappable>(_ queries: [Query]) -> Promise<[T]?> {
        return Promise<[T]?> { fulfill, reject in

            let requests = queries.map { PageRequest(query: $0) }

            firstly {
                when(fulfilled: requests.map { $0.resume() })
            }.then { responses -> Void in

                self.nextPageableComponents = {
                    let next = responses.filter { $0.pages.next != nil }.map { $0.pages.next! }

                    return next.count > 0 ? next : nil
                }()
                self.previousPageableComponents = {
                    let previous = responses.filter { $0.pages.previous != nil }.map { $0.pages.previous! }

                    return previous.count > 0 ? previous : nil
                }()

                let result = responses
                    .map { $0.json?.arrayValue.map { T.map( $0 != JSON.null && self.serializationKey != nil ?
                        $0[self.serializationKey!] : $0 ) } }
                    .flatMap { $0 }
                    .flatMap { $0 }

                fulfill(result)

            }.catch(execute: reject)
        }
    }

    func queryByPagingConfiguration(_ query: Query) -> Query {
        var resultQuery = query
        resultQuery.parameters["page"] = page as AnyObject?
        resultQuery.parameters["per_page"] = pagination as AnyObject?

        return resultQuery
    }
}
