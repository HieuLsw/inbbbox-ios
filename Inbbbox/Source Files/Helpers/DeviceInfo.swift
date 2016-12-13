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
}
