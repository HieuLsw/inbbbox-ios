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
    private var tasks = [NSURLSessionTask]()

    /// Fetches data from given URL and gives information about progress and completion of operation.
    /// Will not fetch if task with given url is already in progress.
    ///
    /// - parameter url:        URL to fetch data from.
    /// - parameter progress:   Block called every time when portion of data is fetched.
    ///                         Gives information about progress.
    /// - parameter completion: Block called when fetching is complete. It returns fetched data as parameter.
    func fetchData(url: NSURL, progress:(progress: Float) -> Void, completion:(data: NSData) -> Void) {
        
        guard !isTaskWithUrlAlreadyInProgress(url) else {
            return
        }
        
        self.progress = progress
        self.completion = completion
        session = NSURLSession.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                                         delegate: self,
                                         delegateQueue: nil)
        if let task = session?.dataTaskWithURL(url) {
            tasks.append(task)
            task.resume()
        }
    }
    
    /// Cancel all NSURLSessionDataTask that are in progress
    ///
    func cancelAllFetching() {
        for task in tasks {
            task.cancel()
        }
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
            session.invalidateAndCancel()
            tasks.removeIfContains(dataTask)
            return
            
        }
        self.data.appendData(data)
        progress?(percentOfProgress)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        guard error == nil else { return }
        completion?(NSData(data: self.data))
    }
}

private extension DataDownloader {
    
    func isTaskWithUrlAlreadyInProgress(url: NSURL) -> Bool {
        for task in tasks where task.currentRequest?.URL?.absoluteString == url.absoluteString {
            return true
        }
        return false
    }
}
