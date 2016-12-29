//
//  StreamSourceView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import PureLayout
import UIKit

class StreamSourceView: UIView {
    
    private lazy var blurView: UIVisualEffectView = {
        UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
    }()
    
    private(set) lazy var followingView = SingleStreamView(
        streamName: NSLocalizedString("SettingsViewModel.Following", comment: ""),
        streamSourceKey: .followingStreamSourceOn
    )
    
    private(set) lazy var newTodayView = SingleStreamView(
        streamName: NSLocalizedString("SettingsViewModel.NewToday", comment: ""),
        streamSourceKey: .newTodayStreamSourceOn
    )
    
    private(set) lazy var popularTodayView = SingleStreamView(
        streamName: NSLocalizedString("SettingsViewModel.Popular", comment: ""),
        streamSourceKey: .popularTodayStreamSourceOn
    )
    
    private(set) lazy var debutsView = SingleStreamView(
        streamName: NSLocalizedString("SettingsViewModel.Debuts", comment: ""),
        streamSourceKey: .debutsStreamSourceOn
    )
    
    private(set) lazy var mySetView = SingleStreamView(
        streamName: "My set",
        streamSourceKey: .mySetStreamSourceOn
    )
    
    private lazy var stackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(
            arrangedSubviews: [
                self.followingView,
                SeparatorView(axis: .vertical, thickness: 1, color: .streamSourceGrayColor()),
                self.newTodayView,
                SeparatorView(axis: .vertical, thickness: 1, color: .streamSourceGrayColor()),
                self.popularTodayView,
                SeparatorView(axis: .vertical, thickness: 1, color: .streamSourceGrayColor()),
                self.debutsView,
                SeparatorView(axis: .vertical, thickness: 1, color: .streamSourceGrayColor()),
                self.mySetView
            ]
        )

        stackView.axis = .vertical
        
        return stackView
    }()
    
    private(set) lazy var roundedView: UIView = { [unowned self] in
        let view = UIView()
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        setupBlur()
        setupProperties()
        setupHierarchy()
        setupConstraints()
    }
    
    @available(*, unavailable, message: "Use init() instead")
    override init(frame: CGRect) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "Use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBlur() {
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func setupProperties() {
        backgroundColor = UIColor.clear
    }
    
    private func setupHierarchy() {
        addSubview(blurView)
        roundedView.addSubview(stackView)
        addSubview(roundedView)
    }
    
    private func setupConstraints() {
        roundedView.autoAlignAxis(toSuperviewAxis: .horizontal)
        roundedView.autoAlignAxis(toSuperviewAxis: .vertical)
        roundedView.autoPinEdge(toSuperviewEdge: .right, withInset: 50)
        roundedView.autoPinEdge(toSuperviewEdge: .left, withInset: 50)
        
        stackView.autoPinEdgesToSuperviewEdges()
    }
    
}
