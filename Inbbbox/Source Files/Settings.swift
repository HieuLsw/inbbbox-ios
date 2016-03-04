//
//  Settings.swift
//  Inbbbox
//
//  Created by Peter Bruz on 04/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

class Settings {
    
    struct StreamSource {
        
        static var IsSet: Bool {
            get { return Settings.boolForKey(.StreamSourceIsSet) }
            set { Settings.setValue(newValue, forKey: .StreamSourceIsSet) }
        }
        
        static var Following: Bool {
            get { return Settings.boolForKey(.FollowingStreamSourceOn) }
            set { Settings.setValue(newValue, forKey: .FollowingStreamSourceOn) }
        }
        
        static var NewToday: Bool {
            get { return Settings.boolForKey(.NewTodayStreamSourceOn) }
            set { Settings.setValue(newValue, forKey: .NewTodayStreamSourceOn) }
        }
        
        static var PopularToday: Bool {
            get { return Settings.boolForKey(.PopularTodayStreamSourceOn) }
            set { Settings.setValue(newValue, forKey: .PopularTodayStreamSourceOn) }
        }
        
        static var Debuts: Bool {
            get { return Settings.boolForKey(.DebutsStreamSourceOn) }
            set { Settings.setValue(newValue, forKey: .DebutsStreamSourceOn) }
        }
    }
    
    struct Reminder {
        
        static var Enabled: Bool {
            get { return Settings.boolForKey(.ReminderOn) }
            set { Settings.setValue(newValue, forKey: .ReminderOn) }
        }
        
        static var Date: NSDate? {
            get { return Settings.dateForKey(.ReminderDate) }
            set { Settings.setValue(newValue, forKey: .ReminderDate) }
        }
        
        static var LocalNotificationSettingsProvided: Bool {
            get { return Settings.boolForKey(.LocalNotificationSettingsProvided) }
            set { Settings.setValue(newValue, forKey: .LocalNotificationSettingsProvided) }
        }
    }
}

private extension Settings {
    
    static func boolForKey(key: DefaultsKey) -> Bool {
        return Defaults[key.rawValue].bool ?? false
    }
    
    static func dateForKey(key: DefaultsKey) -> NSDate? {
        return Defaults[key.rawValue].date
    }
    
    static func setValue(value: AnyObject?, forKey key: DefaultsKey) {
        Defaults[key.rawValue] = value
    }
}
