//
//  ProgressAnimator.swift
//  Inbbbox
//
//  Created by Kamil Tomaszewski on 25/05/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

class ProgressAnimator {

    var progressImageView = UIImageView()

    /// Base name of image file
    fileprivate let baseName: String!
    /// Maximum count of images in animation
    fileprivate let maximumImageCount: Int!
    /// Current limit of frames to animate
    fileprivate var maximumFrameIndex = 0
    /// Current frame index
    fileprivate var currentFrameIndex = 0
    /// Time span between frame updates
    fileprivate var timeTick = 0.01
    /// Completion handler when currentFrameIndex reach maximumFrameIndex
    fileprivate var onDidCompleteAnimation: (()->Void)?
    /// Timer that swaps images
    fileprivate var timer: Timer!
    // MARK: Public

    /// Default initializer
    ///
    /// - parameter imageBaseName:     Common part of files' names with separator i.e loadgif_
    /// - parameter imageCount:     Number of files that should become the animation.
    ///
    /// - returns: instance of ProgressAnimator
    init(imageBaseName: String, imageCount: Int) {
        baseName = imageBaseName
        maximumImageCount = imageCount
        timer = Timer.scheduledTimer(timeInterval: timeTick, target: self, selector: #selector(self.updateFrame), userInfo: nil, repeats: true)
    }

    /// Updates progress of animation according to passed value
    ///
    /// - parameter progress:   Progress value between 0.0 - 1.0. If you pass higher value than 1.0 it will be
    ///                         locked to 1.0 value
    /// - parameter complete:   Block that is called when currentFrameIndex reache maximumFrameIndex
    func updateProgress(progress: Float, onComplete complete: (()->Void)? = nil) {
        
        let newFrameLimit = interpolateProgress(progress: min(1.0, progress))
        guard maximumFrameIndex < newFrameLimit  else {
            return
        }
        
        maximumFrameIndex = newFrameLimit
        onDidCompleteAnimation = complete
        if !timer.isValid && currentFrameIndex < maximumImageCount  {
            timer = Timer.scheduledTimer(timeInterval: timeTick, target: self, selector: #selector(self.updateFrame), userInfo: nil, repeats: true)
        }
    }
}

fileprivate extension ProgressAnimator {
    
    @objc func updateFrame(timer: Timer) {
        guard currentFrameIndex <= maximumFrameIndex && isFrameInBounds() else {
            timer.invalidate()
            return
        }
        
        progressImageView.image = image(frameIndex: currentFrameIndex)
        currentFrameIndex += 1
        
        if !isFrameInBounds() {
            onDidCompleteAnimation?()
        }
    }
    
    func isFrameInBounds() -> Bool {
        return currentFrameIndex <= maximumImageCount
    }
    
    func interpolateProgress(progress: Float) -> Int {
        let maximum = Float(maximumImageCount)
        let animationFrameKey = maximum * progress
        return Int(animationFrameKey)
    }
    
    func imageName(frameIndex: Int) -> String {
        return baseName + String(frameIndex)
    }
    
    func image(frameIndex: Int) -> UIImage? {
        return UIImage(named: imageName(frameIndex: frameIndex))
    }
}
