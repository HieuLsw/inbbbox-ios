//
//  PageableComponent.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 28/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct PageableComponent {

    let path: String
    let queryItems: [URLQueryItem]?

    init(path: String, query: String?) {
        self.path = path
        self.queryItems = query?.queryItems
    }
}

private extension String {

    var queryItems: [URLQueryItem]? {

        return components(separatedBy: "&").map { component -> URLQueryItem in
            let components = component.components(separatedBy: "=")
            return URLQueryItem(name: components[0], value: components[1])
        }
    }
}

extension PageableComponent: CustomDebugStringConvertible {

    var debugDescription: String {

        let items = queryItems?
            .map { "\($0.name)=\(String(describing: $0.value))" }
            .reduce("", { $0 == "" ? $1 : $0 + "&" + $1 })

        return path + "?" + (items ?? "")
    }
}
