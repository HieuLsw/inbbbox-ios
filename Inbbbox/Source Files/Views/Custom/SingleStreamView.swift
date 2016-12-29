//
//  SingleStreamView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import PureLayout
import UIKit

final class SingleStreamView: UIView {
    
    private let streamName: String
    private let streamSource: ShotsSource
    
    var didSelectStreamSourceClosure: ((ShotsSource) -> Void)? = nil
    var isStreamSelected: Bool = false {
        didSet {
            checkmarkImageView.isHidden = !isStreamSelected
            streamNameLabel.textColor = isStreamSelected ? .pinkColor() : .streamSourceGrayColor()
            streamNameLabel.font = UIFont.systemFont(ofSize: 17, weight: isStreamSelected ? UIFontWeightSemibold : UIFontWeightRegular)
        }
    }
    
    private(set) lazy var checkmarkImageView: UIImageView = { [unowned self] in
        let imageView = UIImageView(image: UIImage(named: "ic-checkmark"))
        
        imageView.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        
        return imageView
    }()
    
    private(set) lazy var streamNameLabel: UILabel = { [unowned self] in
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightRegular)
        label.textColor = .streamSourceGrayColor()
        label.text = self.streamName
        label.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .horizontal)
        
        return label
    }()
    
    private lazy var stackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(
            arrangedSubviews: [
                self.streamNameLabel,
                self.checkmarkImageView
            ]
        )
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        
        return stackView
    }()
    
    init(streamName: String, streamSource: ShotsSource) {
        self.streamName = streamName
        self.streamSource = streamSource
        super.init(frame: .zero)
        setupHierarchy()
        setupConstraints()
        setupActions()
    }
    
    @available(*, unavailable, message: "Use init() instead")
    override init(frame: CGRect) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "Use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHierarchy() {
        addSubview(stackView)
    }
    
    private func setupConstraints() {
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsetsMake(10, 16, 10, 16))
    }
    
    private func setupActions() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapSingleSourceView)))
    }
    
    dynamic private func didTapSingleSourceView() {
        didSelectStreamSourceClosure?(streamSource)
    }
    
}
