//
//  CloseButtonView.swift
//  Inbbbox
//
//  Created by Peter Bruz on 16/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class CloseButtonView: UIView {

    let closeButton = UIButton(type: .system)
    let vibrancyView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let dimView = UIView.newAutoLayout()

    fileprivate let diameterSize = CGFloat(26)
    fileprivate var didSetConstraints = false

    // MARK: - Life cycle

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        vibrancyView.layer.cornerRadius = diameterSize/2
        vibrancyView.clipsToBounds = true
        addSubview(vibrancyView)

        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        vibrancyView.addSubview(dimView)

        closeButton.configureForAutoLayout()
        closeButton.backgroundColor = UIColor.white.withAlphaComponent(0.01)
        let image = UIImage(named: "ic-cross-naked")?.withRenderingMode(.alwaysOriginal)
        closeButton.setImage(image, for: .normal)
        addSubview(closeButton)
    }

    override func updateConstraints() {
        if !didSetConstraints {
            didSetConstraints = true

            closeButton.autoPinEdgesToSuperviewEdges()
            dimView.autoCenterInSuperview()
            dimView.autoSetDimensions(to: CGSize(width: diameterSize, height: diameterSize))
            vibrancyView.autoCenterInSuperview()
            vibrancyView.autoSetDimensions(to: CGSize(width: diameterSize, height: diameterSize))

            let diameterMultiplier = CGFloat(1.5)
            let selfSize = CGSize(width: diameterSize * diameterMultiplier, height: diameterSize * diameterMultiplier)
            autoSetDimensions(to: selfSize)
        }
        super.updateConstraints()
    }
}
