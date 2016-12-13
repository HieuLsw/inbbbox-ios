//
//  DeviceInfo.swift
//  Inbbbox
//
//  Created by Tomasz W on 30/09/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import DeviceKit

final class DeviceInfo {

    class func shouldDowngrade() -> Bool {
        return Device().isOneOf([Device.iPadMini, Device.iPhone4s])
    }
    
    class func notsupports3DTouch() -> Bool {
        let iPhonesWithout3DTouch = [Device.iPhone6Plus, Device.iPhone6, Device.iPhone5s, Device.iPhone5, Device.iPhone4s]
        let simulatorIPhoneWithout3DTouch = iPhonesWithout3DTouch.map() { Device.simulator($0) }
        return Device().isOneOf(Device.allPads + Device.allPods + iPhonesWithout3DTouch + simulatorIPhoneWithout3DTouch)
    }
}
