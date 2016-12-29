//
//  StreamSourceViewController.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

final class StreamSourceViewController: UIViewController {

    private let viewModel: StreamSourceViewModel
    
    private var profileInfoView: StreamSourceView! {
        return view as? StreamSourceView
    }
    
    private let didSelectStream: () -> Void
    
    init(didSelectStream: @escaping () -> Void) {
        self.didSelectStream = didSelectStream
        self.viewModel = StreamSourceViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "Use init(didSelectStream:) instead")
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    @available(*, unavailable, message: "Use init(didSelectStream:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = StreamSourceView(didSelectStreamSourceClosure: { [unowned self] streamSourceType in
            self.viewModel.didSelectStreamSource(streamSource: streamSourceType.rawValue)
            self.setupUI()
            self.didSelectStream()
            self.dismiss(animated: true, completion: nil)
        })
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        profileInfoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOutsidePopup)))
        setupUI()
    }
    
    private func setupUI() {
        profileInfoView.followingView.isStreamSelected = viewModel.isFollowingStreamSelected
        profileInfoView.newTodayView.isStreamSelected = viewModel.isNewTodayStreamSelected
        profileInfoView.popularTodayView.isStreamSelected = viewModel.isPopularTodayStreamSelected
        profileInfoView.debutsView.isStreamSelected = viewModel.isDebutsStreamSelected
        profileInfoView.mySetView.isStreamSelected = viewModel.isMySetStreamSelected
    }
    
    dynamic private func didTapOutsidePopup() {
        dismiss(animated: true, completion: nil)
    }
    
}
