//
//  AutoScrollableCollectionViewCell.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 28/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit.UICollectionViewCell
import PureLayout

class AutoScrollableCollectionViewCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    private var didSetConstraints = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
      
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        setNeedsUpdateConstraints()
    }
    
    @available(*, unavailable, message="Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        if !didSetConstraints {
            didSetConstraints = true
            
            imageView.autoPinEdgesToSuperviewEdges()            
        }

        super.updateConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
}
