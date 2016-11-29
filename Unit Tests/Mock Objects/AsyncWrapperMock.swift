//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Dobby

@testable import Inbbbox

class AsyncWrapperMock: AsyncWrapper {

    let mainStub = Stub<(Double?, ()->()), AsyncWrapper>()

    override func main(after: Double?, block: @escaping () -> ()) -> AsyncWrapper {
        return try! mainStub.invoke(after, block)
    }
}
