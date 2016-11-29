//
// Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import Dobby

@testable import Inbbbox

class CollectionViewMock: UICollectionView {

    let numberOfItemsInSectionStub = Stub<Int, Int>()
    let insertItemsAtIndexPathsStub = Stub<[IndexPath], Void>()
    let deleteItemsAtIndexPathsStub = Stub<[IndexPath], Void>()
    let performBatchUpdatesStub = Stub<((() -> Void)?, ((Bool) -> Void)?), Void>()
    let reloadDataStub = Stub<Void, Void>()
    let dequeueReusableCellWithReuseIdentifierStub = Stub<(String, IndexPath), UICollectionViewCell>()
    let visibleCellsStub = Stub<Void, [UICollectionViewCell]>()
    let indexPathForCellStub = Stub<UICollectionViewCell, IndexPath>()

    convenience init() {
        self.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    }

    override func numberOfItems(inSection section: Int) -> Int {
        return try! numberOfItemsInSectionStub.invoke(section)
    }

    override func insertItems(at indexPaths: [IndexPath]) {
        try! insertItemsAtIndexPathsStub.invoke(indexPaths)
    }

    override func deleteItems(at indexPaths: [IndexPath]) {
        try! deleteItemsAtIndexPathsStub.invoke(indexPaths)
    }

    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?) {
        try! performBatchUpdatesStub.invoke(updates, completion)
    }

    override func reloadData() {
        try! reloadDataStub.invoke()
    }

    override func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        return try! dequeueReusableCellWithReuseIdentifierStub.invoke(identifier, indexPath)
    }

    override var visibleCells : [UICollectionViewCell] {
        return try! visibleCellsStub.invoke()
    }

    override func indexPath(for cell: UICollectionViewCell) -> IndexPath? {
        return try! indexPathForCellStub.invoke(cell)
    }
}
