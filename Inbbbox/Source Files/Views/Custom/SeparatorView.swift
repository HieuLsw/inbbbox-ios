//
//  SeparatorView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

final class SeparatorView: UIView {

    private let axis: Axis
    private let thickness: Double
    private let color: UIColor

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(axis: Axis, thickness: Double, color: UIColor) {
        self.axis = axis
        self.thickness = thickness
        self.color = color
        super.init(frame: .zero)
        setupProperties()
    }

    private func setupProperties() {
        backgroundColor = color
        setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: axis == .vertical ? .vertical : .horizontal)
    }

    override var intrinsicContentSize: CGSize {
        switch axis {
            case .vertical:
                return CGSize(width: UIViewNoIntrinsicMetric, height: CGFloat(thickness))
            case .horizontal:
                return CGSize(width: CGFloat(thickness), height: UIViewNoIntrinsicMetric)
        }
    }

}

extension SeparatorView {
    enum Axis {
        case vertical
        case horizontal
    }
}
