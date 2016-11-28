//
//  ActivityIndicatorSelectableView.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 29/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

enum ActivityIndicatorSelectableViewState {
    case selected, deselected
}

class ActivityIndicatorSelectableView: UIView {

    var selected: Bool {
        get { return button.isSelected }
        set { button.isSelected = newValue }
    }

    var tapHandler: (() -> Void)?

    fileprivate let bouncingBall: BouncingView
    fileprivate let button = UIButton(type: .custom)

    fileprivate var didSetConstraints = false
    fileprivate var wasSelectedBeforeAnimationStart = false

    override init(frame: CGRect) {
        bouncingBall = BouncingView(frame: frame, jumpHeight: 20, jumpDuration: 0.8)
        bouncingBall.configureForAutoLayout()
        super.init(frame: frame)

        button.configureForAutoLayout()
        button.imageView?.backgroundColor = .clear
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(), for: .disabled)
        button.addTarget(self, action: #selector(buttonDidTap(_:)), for: .touchUpInside)
        addSubview(button)

        addSubview(bouncingBall)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override func updateConstraints() {
        if !didSetConstraints {
            didSetConstraints = true

            button.autoPinEdgesToSuperviewEdges()
            bouncingBall.autoPinEdgesToSuperviewEdges()
        }
        super.updateConstraints()
    }

    func setImage(_ image: UIImage?, forState state: ActivityIndicatorSelectableViewState) {
        button.setImage(image, for: state.controlState)
    }

    func startAnimating() {
        if !bouncingBall.shouldAnimate {
            bouncingBall.startAnimating()
        }
        button.isHidden = true
    }

    func stopAnimating() {
        button.isHidden = false
        bouncingBall.stopAnimating()
    }
}

private extension ActivityIndicatorSelectableView {

    dynamic func buttonDidTap(_: UIButton) {
        tapHandler?()
    }
}

private extension ActivityIndicatorSelectableViewState {

    var controlState: UIControlState {
        return self == .selected ? .selected : .normal
    }
}
