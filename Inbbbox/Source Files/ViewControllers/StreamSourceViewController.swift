//
//  StreamSourceViewController.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

final class StreamSourceViewController: UIViewController {

    fileprivate let viewModel: StreamSourceViewModel
    
    fileprivate var profileInfoView: StreamSourceView! {
        return view as? StreamSourceView
    }
    
    init() {
        viewModel = StreamSourceViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "Use init() instead")
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    @available(*, unavailable, message: "Use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = StreamSourceView()
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        profileInfoView.followingView.isStreamSelected = viewModel.isFollowingStreamSelected
        profileInfoView.newTodayView.isStreamSelected = viewModel.isNewTodayStreamSelected
        profileInfoView.popularTodayView.isStreamSelected = viewModel.isPopularTodayStreamSelected
        profileInfoView.debutsView.isStreamSelected = viewModel.isDebutsStreamSelected
        profileInfoView.mySetView.isStreamSelected = viewModel.isMySetStreamSelected
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOutsidePopup)))
    }
    
    dynamic private func didTapOutsidePopup() {
        dismiss(animated: true, completion: nil)
    }
    
}
