//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import Dobby

@testable import Inbbbox

class ShotCollectionViewCellDelegateMock: ShotCollectionViewCellDelegate{

    let shotCollectionViewCellDidStartSwipingStub = Stub<ShotCollectionViewCell, Void>()
    let shotCollectionViewCellDidEndSwipingStub = Stub<ShotCollectionViewCell, Void>()

    func shotCollectionViewCellDidStartSwiping(shotCollectionViewCell: ShotCollectionViewCell) {
        try! shotCollectionViewCellDidStartSwipingStub.invoke(shotCollectionViewCell)
    }

    func shotCollectionViewCellDidEndSwiping(shotCollectionViewCell: ShotCollectionViewCell) {
        try! shotCollectionViewCellDidEndSwipingStub.invoke(shotCollectionViewCell)
    }
}
