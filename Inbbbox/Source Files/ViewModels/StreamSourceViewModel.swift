//
//  StreamSourceViewModel.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

final class StreamSourceViewModel {
    
    var isFollowingStreamSelected: Bool {
        return Settings.StreamSource.Following && !Settings.StreamSource.MySet
    }
    
    var isNewTodayStreamSelected: Bool {
        return Settings.StreamSource.NewToday && !Settings.StreamSource.MySet
    }
    
    var isPopularTodayStreamSelected: Bool {
        return Settings.StreamSource.PopularToday && !Settings.StreamSource.MySet
    }
    
    var isDebutsStreamSelected: Bool {
        return Settings.StreamSource.Debuts && !Settings.StreamSource.MySet
    }
    
    var isMySetStreamSelected: Bool {
        return Settings.StreamSource.MySet
    }
    
}
