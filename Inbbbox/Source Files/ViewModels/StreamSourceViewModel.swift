//
//  StreamSourceViewModel.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

struct StreamSourceViewModel {
    
    var isFollowingStreamSelected: Bool {
        return Settings.StreamSource.SelectedStreamSource == .following
    }
    
    var isNewTodayStreamSelected: Bool {
        return Settings.StreamSource.SelectedStreamSource == .newToday
    }
    
    var isPopularTodayStreamSelected: Bool {
        return Settings.StreamSource.SelectedStreamSource == .popularToday
    }
    
    var isDebutsStreamSelected: Bool {
        return Settings.StreamSource.SelectedStreamSource == .debuts
    }
    
    var isMySetStreamSelected: Bool {
        return Settings.StreamSource.SelectedStreamSource == .mySet
    }
    
    func didSelectStreamSource(streamSource: ShotsSource) {
        Settings.StreamSource.SelectedStreamSource = streamSource
    }
    
}
