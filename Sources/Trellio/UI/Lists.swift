import UIKit
import PTDList
import Combine

public final class TRUIListCell: UICollectionViewListCell, PTDListCell {
    public typealias Item = TRList
    public func setup(context: PTDListContext<TRUIListCell>) {
        var config = UIListContentConfiguration.cell()
        config.text = context.item.name
        contentConfiguration = config
        accessories = [
            .disclosureIndicator()
        ]
    }
}

public final class TRUIListsController: PTDListController<TRUIListCell> {
    
    private var subscriptions = Set<AnyCancellable>()
    
    public var mode: Mode? {
        didSet {
            getLists()
        }
    }
    
    private var trBoard: TRBoard?
    
    private func getLists() {
        guard let mode = mode else { return }
        let publisher: AnyPublisher<[TRList], TRError>
        
        switch mode {
        case let .board(board):
            publisher = board.getLists().eraseToAnyPublisher()
        case let .id(id):
            publisher = Trellio.getLists(boardId: id).eraseToAnyPublisher()
        }
        publisher
            .catch { err -> Empty<[TRList], Never> in
                print(err)
                return .init()
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.items = $0
            }
            .store(in: &subscriptions)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        action = { [weak self] context in
            let list = TRUICardListController()
            list.mode = .list(context.item)
            self?.show(list, sender: self)
        }
        #if !os(tvOS)
        navigationController?.navigationBar.prefersLargeTitles = true
        #endif
    }
    
    public enum Mode {
        case board(TRBoard), id(String)
    }
    
    private func updateTitle() {
        switch mode {
        case let .board(board):
            title = board.name
            trBoard = board
        default: title = "Lists"
        }
    }
}
