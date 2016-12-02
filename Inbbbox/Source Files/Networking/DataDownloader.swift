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
    fileprivate var tasks = [URLSessionTask]()


    /// Fetches data from given URL and gives information about progress and completion of operation.
    /// Will not fetch if task with given url is already in progress.
    ///
    /// - parameter url:        URL to fetch data from.
    /// - parameter progress:   Block called every time when portion of data is fetched.
    ///                         Gives information about progress.
    /// - parameter completion: Block called when fetching is complete. It returns fetched data as parameter.
    func fetchData(_ url: URL, progress:@escaping (_ progress: Float) -> Void, completion:@escaping (_ data: Data) -> Void) {
        
        guard !isTaskWithUrlAlreadyInProgress(with: url) else { return }
        
        self.progress = progress
        self.completion = completion
        session = URLSession.init(configuration: URLSessionConfiguration.default,
                                         delegate: self,
                                         delegateQueue: nil)
        if let task = session?.dataTask(with: url) {
            print("add new task \(task.hash)")
            tasks.append(task)
            task.resume()
        }
    }
    
    /// Cancel all NSURLSessionDataTask that are in progress
    ///
    func cancelAllFetching() {
        tasks.forEach() { $0.cancel() }
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
            session.invalidateAndCancel()
            tasks.remove(ifContains: dataTask)
            return
            
        }

        self.data.append(data)
        progress?(percentOfProgress)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard error == nil else { return }
        print("complete task \(task.hash)")
        completion?(self.data as Data)
    }
}

private extension DataDownloader {
    
    func isTaskWithUrlAlreadyInProgress(with url: URL) -> Bool {
        return tasks.contains() { task -> Bool in
            return task.currentRequest?.url?.absoluteString == url.absoluteString
        }
    }
}
