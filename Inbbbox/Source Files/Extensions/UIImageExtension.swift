//
//  UIImageExtension.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/10/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import GPUImage

extension UIImage {

    // MARK: Initializers

    /// Initializes the image with color and size.
    /// By default width and height are set to 1.
    ///
    /// - Parameters:
    ///     - color: `UIColor` the image will be filled with.
    ///     - size: Size of the image.
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }

    /// Blurred image.
    ///
    /// - parameter blur: float value of blur added to image
    ///
    /// - returns: blurred image
    func imageByBlurringImageWithBlur(_ blur: CGFloat) -> UIImage {
        let maxBlurRadius = CGFloat(1)
        let blurFilter = GPUImageGaussianBlurFilter()
        blurFilter.blurRadiusInPixels = blur * maxBlurRadius

        return blurFilter.image(byFilteringImage: self)
    }
}
