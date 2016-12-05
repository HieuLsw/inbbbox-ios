//
//  AttachmentCollectionViewCell.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 15.11.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

class AttachmentCollectionViewCell: UICollectionViewCell {
    
    let imageView = UIImageView.newAutoLayoutView()
    private let attachmentIconImageView = UIImageView.newAutoLayoutView()
    
    private var didUpdateConstraints = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureForAutoLayout()
        
        contentView.configureForAutoLayout()
        contentView.backgroundColor = .clearColor()
        
        imageView.contentMode = .ScaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 3
        contentView.addSubview(imageView)
        
        attachmentIconImageView.image = UIImage(named: "ic_attachment")
        attachmentIconImageView.contentMode = .Center
        attachmentIconImageView.layer.cornerRadius = 9
        attachmentIconImageView.backgroundColor = UIColor.RGBA(175, 175, 175, 0.26)
        contentView.addSubview(attachmentIconImageView)
        
        setNeedsUpdateConstraints()
    }
    
    @available(*, unavailable, message = "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        if !didUpdateConstraints {
            didUpdateConstraints = true
            
            imageView.autoPinEdgesToSuperviewEdges()
            attachmentIconImageView.autoPinEdgeToSuperviewEdge(.Right, withInset: 3)
            attachmentIconImageView.autoPinEdgeToSuperviewEdge(.Top, withInset: 3)
            attachmentIconImageView.autoSetDimensionsToSize(CGSizeMake(18, 18))
            
            contentView.autoPinEdgesToSuperviewEdges()
        }
        
        super.updateConstraints()
    }
}

extension AttachmentCollectionViewCell: Reusable {
    
    class var reuseIdentifier: String {
        return String(AttachmentCollectionViewCell)
    }
}
