//
//  SingleStreamView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import PureLayout
import UIKit

class SingleStreamView: UIView {
    
    private let streamName: String
    
    private lazy var checkmarkImageView: UIImageView = { [unowned self] in
        let imageView = UIImageView(image: UIImage(named: "ic-checkmark"))
        
        imageView.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        imageView.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
        
        return imageView
    }()
    
    private(set) lazy var streamNameLabel: UILabel = { [unowned self] in
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightSemibold)
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
    
    init(streamName: String) {
        self.streamName = streamName
        super.init(frame: .zero)
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
    
    private func setupHierarchy() {
        addSubview(stackView)
    }
    
    private func setupConstraints() {
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsetsMake(10, 16, 10, 16))
    }
    
}
