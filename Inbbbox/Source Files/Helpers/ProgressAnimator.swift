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
    private let baseName: String!
    /// Maximum count of images in animation
    private let maximumImageCount: Int!
    /// Current limit of frames to animate
    private var maximumFrameIndex = 0
    /// Current frame index
    private var currentFrameIndex = 0
    /// Time span between frame updates
    private var timeTick = 0.01
    /// Completion handler when currentFrameIndex reach maximumFrameIndex
    private var onDidCompleteAnimation: (()->Void)?
    /// Timer that swaps images
    private var timer: NSTimer!
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
        timer = NSTimer.scheduledTimerWithTimeInterval(timeTick, target: self, selector: #selector(self.updateFrame), userInfo: nil, repeats: true)
    }

    /// Updates progress of animation according to passed value
    ///
    /// - parameter progress:   Progress value between 0.0 - 1.0. If you pass higher value than 1.0 it will be
    ///                         locked to 1.0 value
    /// - parameter complete:   Block that is called when currentFrameIndex reache maximumFrameIndex
    func updateProgress(progress: Float, onComplete complete: (()->Void)? = nil) {
        onDidCompleteAnimation = complete
        
        guard progress < 1.0 else {
            maximumFrameIndex = maximumImageCount
            if (!timer.valid) {
                recreateTimer()
            }
            return
        }
        
        let newFrameLimit = interpolateProgress(min(1.0, progress))
        
        guard maximumFrameIndex < newFrameLimit else { return }
        
        maximumFrameIndex = newFrameLimit
        if !timer.valid && currentFrameIndex < maximumImageCount  {
            recreateTimer()
        }
    }
}

private extension ProgressAnimator {
    
    func recreateTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(timeTick, target: self, selector: #selector(self.updateFrame(_:)), userInfo: nil, repeats: true)
    }
    
    @objc func updateFrame(timer: NSTimer) {
        guard currentFrameIndex <= maximumFrameIndex && isFrameInBounds() else {
            timer.invalidate()
            return
        }
        
        progressImageView.image = image(currentFrameIndex)
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
        return UIImage(named: imageName(frameIndex))
    }
}
