//
//  StreamSourceView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import PureLayout
import UIKit

final class StreamSourceView: UIView {
    
    private let didSelectStreamSourceClosure: (ShotsSource) -> Void
    
    private lazy var blurView: UIVisualEffectView = {
        UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
    }()
    
    private(set) lazy var followingView: SingleStreamView = SingleStreamView(
        streamName: Localized("SettingsViewModel.Following", comment: ""),
        streamSource: .following
    )
    
    private(set) lazy var newTodayView = SingleStreamView(
        streamName: Localized("SettingsViewModel.NewToday", comment: ""),
        streamSource: .newToday
    )
    
    private(set) lazy var popularTodayView = SingleStreamView(
        streamName: Localized("SettingsViewModel.Popular", comment: ""),
        streamSource: .popularToday
    )
    
    private(set) lazy var debutsView = SingleStreamView(
        streamName: Localized("SettingsViewModel.Debuts", comment: ""),
        streamSource: .debuts
    )
    
    private(set) lazy var mySetView = SingleStreamView(
        streamName: Localized("SettingsViewModel.MySet", comment: ""),
        streamSource: .mySet
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
    
    init(didSelectStreamSourceClosure: @escaping (ShotsSource) -> Void) {
        self.didSelectStreamSourceClosure = didSelectStreamSourceClosure
        super.init(frame: .zero)
        setupBlur()
        setupProperties()
        setupHierarchy()
        setupConstraints()
        setupSubvies()
    }
    
    @available(*, unavailable, message: "Use init(didSelectStreamSourceClosure:) instead")
    override init(frame: CGRect) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "Use init(didSelectStreamSourceClosure:) instead")
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
    
    private func setupSubvies() {
        [followingView, newTodayView, popularTodayView, debutsView, mySetView].forEach { [unowned self] singleStreamView in
            singleStreamView.didSelectStreamSourceClosure = self.didSelectStreamSourceClosure
        }
    }
    
}
