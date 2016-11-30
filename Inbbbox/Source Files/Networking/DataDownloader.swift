//
//  DataDownloader.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 18.03.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import UIKit

class DataDownloader: NSObject {
    fileprivate var data = NSMutableData()
    fileprivate var totalSize = Float(0)
    fileprivate var progress: ((Float) -> Void)?
    fileprivate var completion: ((Data) -> Void)?
    fileprivate var session: URLSession?

    /// Fetches data from given URL and gives information about progress and completion of operation.
    ///
    /// - parameter url:        URL to fetch data from.
    /// - parameter progress:   Block called every time when portion of data is fetched.
    ///                         Gives information about progress.
    /// - parameter completion: Block called when fetching is complete. It returns fetched data as parameter.
    func fetchData(_ url: URL, progress:@escaping (_ progress: Float) -> Void, completion:@escaping (_ data: Data) -> Void) {
        self.progress = progress
        self.completion = completion
        self.session = URLSession(configuration: URLSessionConfiguration.default,
                                  delegate: self,
                                  delegateQueue: nil)
        let task = session!.dataTask(with: url)

        task.resume()
    }
}

extension DataDownloader: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
            completionHandler(.allow)
            totalSize = Float(response.expectedContentLength)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let percentOfProgress = Float(self.data.length) / totalSize
        
        guard percentOfProgress < 1 else {
            completion?(self.data as Data)
            session.invalidateAndCancel()
            return
        }
        
        self.data.append(data)
        progress?(percentOfProgress)
    }
}
