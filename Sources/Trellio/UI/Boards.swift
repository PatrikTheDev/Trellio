import UIKit
import PTDList
import Combine

public final class TRUIBoardCell: UICollectionViewListCell, PTDListCell {
    public typealias Item = TRBoard
    public func setup(context: PTDListContext<TRUIBoardCell>) {
        var config = UIListContentConfiguration.cell()
        config.text = context.item.name
        contentConfiguration = config
        accessories = [
            .disclosureIndicator()
        ]
    }
}

public class TRUIBoardListController: PTDListController<TRUIBoardCell> {
    override public func viewDidLoad() {
        super.viewDidLoad()
        action = { [weak self] context in
            let list = TRUIListsController()
            list.mode = .board(context.item)
            self?.show(list, sender: self)
        }
    }
}
