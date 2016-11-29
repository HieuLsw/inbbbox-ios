//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Async

class AsyncWrapper {

    func main(after: Double? = nil, block: @escaping ()->()) -> AsyncWrapper {
        Async.main(after: after, block)
        return self
    }
}
