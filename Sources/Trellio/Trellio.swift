import Foundation
import Combine

public enum Trellio {
    public static var token = String()
    public static var key = String()
    
    public static func getBoards() -> AnyPublisher<[TRBoard], TRError> {
        checkToken(get(TrelloAPI.Boards.get()))
    }
    
    public static func getLists(boardId id: String) -> AnyPublisher<[TRList], TRError> {
        checkToken(get(TrelloAPI.Lists.get(boardId: id)))
    }
    
    public static func getCards(boardId id: String) -> AnyPublisher<[TRCard], TRError> {
        checkToken(get(TrelloAPI.Cards.get(boardId: id)))
    }
    
    public static func getCards(listId id: String) -> AnyPublisher<[TRCard], TRError> {
        checkToken(get(TrelloAPI.Cards.get(listId: id)))
    }
    
    private static func get<T: Decodable>(_ url: URL?) -> AnyPublisher<T, TRError> {
        guard let url = url else {
            return Fail(error: .unableToConstructURL).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw TRError.noResponse
                }
                guard 200...299 ~= httpResponse.statusCode else {
                    throw TRError.wrongResponse(httpResponse)
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .catch { Fail(error: .unknownError($0)) }
            .eraseToAnyPublisher()
    }
    
    public static func getBoard(id: String) -> AnyPublisher<TRBoard, TRError> {
        checkToken(get(TrelloAPI.Board.get(id: id)))
    }
    
    public static func getList(id: String) -> AnyPublisher<TRList, TRError> {
        checkToken(get(TrelloAPI.List.get(id: id)))
    }
    
    private static func checkToken<T>(_ publisher: AnyPublisher<T, TRError>) -> AnyPublisher<T, TRError> {
        if token.isEmpty || key.isEmpty {
            return Fail(error: .noTokenOrAPIKey).eraseToAnyPublisher()
        } else {
            return publisher
        }
    }
}

public struct TRBoard: Hashable, Codable {
    public var name: String
    public var id: String
    public var starred: Bool
    
    @inlinable
    public func getCards() -> AnyPublisher<[TRCard], TRError> {
        Trellio.getCards(boardId: id)
    }
    @inlinable
    public func getLists() -> AnyPublisher<[TRList], TRError> {
        Trellio.getLists(boardId: id)
    }
}

public struct TRList: Hashable, Codable {
    public var name: String
    public var id: String
    public var idBoard: String
    public var closed: Bool
    
    @inlinable
    public func getCards() -> AnyPublisher<[TRCard], TRError> {
        Trellio.getCards(listId: id)
    }
    
    @inlinable
    public func getBoard() -> AnyPublisher<TRBoard, TRError> {
        Trellio.getBoard(id: idBoard)
    }
}

public struct TRCard: Hashable, Codable {
    public var name: String
    public var id: String
    public var starred: Int?
    
    public var idBoard: String
    public var idList: String

    @inlinable
    public func getBoard() -> AnyPublisher<TRBoard, TRError> {
        Trellio.getBoard(id: idBoard)
    }
    @inlinable
    public func getList() -> AnyPublisher<TRList, TRError> {
        Trellio.getList(id: idList)
    }
}

public enum TRError: Error {
    case noTokenOrAPIKey,
         unableToConstructURL,
         noResponse,
         wrongResponse(HTTPURLResponse),
         unknownError(Error)
}


public enum TrelloAPI {
    public static let hostname = URL(string: "https://api.trello.com/1/")
    public enum Board {
        @inlinable
        public static func get(id: String) -> URL! {
            URL(string: "boards/\(id)?key=\(Trellio.key)&token=\(Trellio.token)", relativeTo: hostname)?.absoluteURL
        }
    }
    public enum Boards {
       @inlinable
        public static func get() -> URL! {
            URL(string: "members/me/boards?key=\(Trellio.key)&token=\(Trellio.token)", relativeTo: hostname)?.absoluteURL
        }
    }
    
    public enum List {
        @inlinable
        public static func get(id: String) -> URL! {
            URL(string: "list/\(id)?key=\(Trellio.key)&token=\(Trellio.token)", relativeTo: hostname)?.absoluteURL
        }
    }
    public enum Lists {
        @inlinable
        public static func get(boardId id: String) -> URL! {
            URL(string: "boards/\(id)/lists?key=\(Trellio.key)&token=\(Trellio.token)", relativeTo: hostname)?.absoluteURL
        }
    }
    
    public enum Cards {
        @inlinable
        public static func get(boardId id: String) -> URL! {
            URL(string: "boards/\(id)/cards?key=\(Trellio.key)&token=\(Trellio.token)", relativeTo: hostname)?.absoluteURL
        }
        @inlinable
        public static func get(listId id: String) -> URL! {
            URL(string: "lists/\(id)/cards?key=\(Trellio.key)&token=\(Trellio.token)", relativeTo: hostname)?.absoluteURL
        }
    }
    
    
}
