//
//  SegmentedCell.swift
//  Inbbbox
//
//  Created by Peter Bruz on 21/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class SegmentedCell: UITableViewCell, Reusable {
    
    class var reuseIdentifier: String {
        return "TableViewSegmentedCellReuseIdentifier"
    }
    
    let segmentedControl = UISegmentedControl()
    
    private var didSetConstraints = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        segmentedControl.insertSegmentWithTitle(NSLocalizedString("-", comment: ""), atIndex: 0, animated: false)
        segmentedControl.insertSegmentWithTitle(NSLocalizedString("+", comment: ""), atIndex: 1, animated: false)
        
        segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
        
        segmentedControl.tintColor = UIColor.pinkColor()
        contentView.insertSubview(segmentedControl, aboveSubview: textLabel!)
        
        setNeedsUpdateConstraints()
    }
    
    @available(*, unavailable, message="Use init(_: UITableViewCellStyle, reuseIdentifier String?) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        if !didSetConstraints {
            didSetConstraints = true
            
            segmentedControl.autoPinEdgeToSuperviewEdge(.Trailing, withInset: 16)
            segmentedControl.autoPinEdgeToSuperviewEdge(.Top, withInset: 7)
            segmentedControl.autoSetDimensionsToSize(CGSize(width: 94, height: 29))
        }
        
        super.updateConstraints()
    }
}

extension SegmentedCell {
    func clearSelection() {
        segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }
}
