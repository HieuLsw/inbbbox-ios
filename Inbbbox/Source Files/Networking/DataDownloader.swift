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
    private var data = NSMutableData()
    private var totalSize = Float(0)
    private var progress: ((Float) -> Void)?
    private var completion: ((NSData) -> Void)?
    private var session: NSURLSession?

    /// Fetches data from given URL and gives information about progress and completion of operation.
    ///
    /// - parameter url:        URL to fetch data from.
    /// - parameter progress:   Block called every time when portion of data is fetched.
    ///                         Gives information about progress.
    /// - parameter completion: Block called when fetching is complete. It returns fetched data as parameter.
    func fetchData(url: NSURL, progress:(progress: Float) -> Void, completion:(data: NSData) -> Void) {
        self.progress = progress
        self.completion = completion
        self.session = NSURLSession.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                                         delegate: self,
                                         delegateQueue: nil)
        let task = session!.dataTaskWithURL(url)

        task.resume()
    }
}

extension DataDownloader: NSURLSessionDataDelegate {
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse,
        completionHandler: (NSURLSessionResponseDisposition) -> Void) {
            completionHandler(.Allow)
            totalSize = Float(response.expectedContentLength)
    }

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        let percentOfProgress = Float(self.data.length) / totalSize
        
        guard percentOfProgress < 1 else {
            completion?(NSData(data: self.data))
            session.invalidateAndCancel()
            return
        }
        
        self.data.appendData(data)
        progress?(percentOfProgress)
    }
}
