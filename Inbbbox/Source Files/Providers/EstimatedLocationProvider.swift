//
//  EstimatedLocationProvider.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 02.12.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON
import PromiseKit

enum EstimatedLocationProviderError: Error {
    case couldNotParseData
}

/// Allows to get estimated user location based on IP.
/// Relies on ip-api.com service.
class EstimatedLocationProvider {
    
    /// ip-api.com is free to use.
    /// Only limit is to not send more than 150 requests/min
    /// because it will result in ban on requester IP.
    /// Docs: http://ip-api.com/docs/
    fileprivate static let ipApiUrl = URL(string: "http://ip-api.com/json")
    
    ///
    /// Allows you to obtain users location based on their IP.
    /// Uses ip-api.com
    ///
    /// - Returns: Promise resolved with estimated distance
    func obtainLocationBasedOnIp() -> Promise<EstimatedLocation> {
        return Promise<EstimatedLocation> { fulfill, reject in
            if let url = EstimatedLocationProvider.ipApiUrl {
                let task = URLSession.inbbboxDefaultSession().dataTask(with: url, completionHandler: { (data, response, error) in
                    if let error = error {
                        reject(error)
                    }
                    if let location = self.estimatedLocationFrom(data: data) {
                        fulfill(location)
                    } else {
                        reject(EstimatedLocationProviderError.couldNotParseData)
                    }
                })
                task.resume()
            }
        }
    }
    
    private func estimatedLocationFrom(data: Data?) -> EstimatedLocation? {
        guard let data = data else {
            return nil
        }
        let json = JSON(data: data)
        let location = EstimatedLocation.map(json)
        return (location.latitude != 0 && location.latitude != 0) ? location : nil
    }

}
