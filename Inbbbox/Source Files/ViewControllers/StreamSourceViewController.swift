//
//  StreamSourceViewController.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class StreamSourceViewController: UIViewController {
    
    override func loadView() {
        view = StreamSourceView()
    }
 
    override func viewDidLoad() {
        view.backgroundColor = .clear
    }
    
}
