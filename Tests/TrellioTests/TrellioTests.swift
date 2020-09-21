import XCTest
@testable import Trellio
import Combine
import PTDList

final class TrellioTests: XCTestCase {
    static var subscriptions = Set<AnyCancellable>()
    func testCardsOnBoard() {
        Trellio.key = Secrets.key
        Trellio.token = Secrets.token
        
        let expectation = XCTestExpectation()
        
        Trellio.getBoards()
            .tryCompactMap(\.first)
            .catch { err -> Empty<TRBoard, Never> in
                XCTFail(err.localizedDescription)
                return Empty<TRBoard, Never>()
            }
            .flatMap { $0.getCards() }
            .catch { err -> Empty<[TRCard], Never> in
                XCTFail("\(err)")
                return Empty<[TRCard], Never>()
            }
            .sink { cards in
                print(cards)
                XCTAssert(!cards.isEmpty, "\(cards.map(\.name))")
                expectation.fulfill()
            }
            .store(in: &Self.subscriptions)
        
        wait(for: [expectation], timeout: 10)
    }
    func testCardsOnList() {
        Trellio.key = Secrets.key
        Trellio.token = Secrets.token
        
        let expectation = XCTestExpectation()
        
        Trellio.getBoards()
            .tryMap { boards -> TRBoard in
                return try XCTUnwrap(boards.first)
            }
            .catch { err -> Empty<TRBoard, Never> in
                XCTFail(err.localizedDescription)
                return Empty<TRBoard, Never>()
            }
            .flatMap { $0.getLists() }
            .tryCompactMap(\.first) // try unwrap, needs a catch closure
            .catch { err -> Empty<TRList, Never> in
                XCTFail("\(err)")
                return .init()
            }
            .flatMap { $0.getCards() }
            .catch { err -> Empty<[TRCard], Never> in
                XCTFail("\(err)")
                return .init()
            }
            .sink { cards in
                XCTAssert(!cards.isEmpty, "\(cards.map(\.name))")
                expectation.fulfill()
            }
            .store(in: &Self.subscriptions)
        
        wait(for: [expectation], timeout: 10)
    }
    func testLists() {
        Trellio.key = Secrets.key
        Trellio.token = Secrets.token
        
        let expectation = XCTestExpectation()
        
        Trellio.getBoards()
            .tryMap { boards -> TRBoard in
                return try XCTUnwrap(boards.first)
            }
            .catch { err -> Empty<TRBoard, Never> in
                XCTFail(err.localizedDescription)
                return .init()
            }
            .flatMap { $0.getLists() }
            .catch { err -> Empty<[TRList], Never> in
                XCTFail(err.localizedDescription)
                return .init()
            }
            .sink { lists in
                print(lists)
                XCTAssert(!lists.isEmpty, "\(lists.map(\.name))")
                expectation.fulfill()
            }
            .store(in: &Self.subscriptions)
        wait(for: [expectation], timeout: 10)
    }
    
    func testBoardsUI() {
        Trellio.key = Secrets.key
        Trellio.token = Secrets.token
        
        let expectation = XCTestExpectation()
        
        let listVC = TRUIBoardListController()
        
        Trellio.getBoards()
            .catch { err -> Empty<[TRBoard], Never> in
                XCTFail(err.localizedDescription)
                return .init()
            }
            .receive(on: RunLoop.main)
            .sink { boards in
                listVC.items = boards
                XCTAssertTrue(listVC.list.dataSource?.collectionView(listVC.list, numberOfItemsInSection: 0) ?? 0 > 0)
                var success = false
                listVC.action = { _ in success = true }
                listVC.list.delegate?.collectionView?(listVC.list, didSelectItemAt: IndexPath(row: 0, section: 0))
                XCTAssertTrue(success)
                expectation.fulfill()
            }
            .store(in: &Self.subscriptions)
        wait(for: [expectation], timeout: 10)
    }

    static var allTests = [
        ("Test cards on a board", testCardsOnBoard),
        ("Test cards on a list", testCardsOnList),
        ("Test lists on a board", testLists),
        ("Test boards UI", testBoardsUI),
    ]
}
