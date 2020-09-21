import Foundation
import Combine

public enum Trellio {
    public static var token = "token"
    public static var key = "key"
    
    private static var subscriptions = Set<AnyCancellable>()
    
    public static func getBoards() -> Future<[TRBoard], TRError> {
        Future<[TRBoard], TRError> { promise in
            if token == "token" || key == "key" {
                return promise(.failure(.noTokenOrAPIKey))
            }
            guard let url = URL(string: "https://api.trello.com/1/members/me/boards?key=\(key)&token=\(token)") else {
                return promise(.failure(.unableToConstructURL))
            }
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                        throw TRError.wrongResponse
                    }
                    return data
                }
                .decode(type: [TRBoard].self, decoder: JSONDecoder())
                .catch { err -> Empty<[TRBoard], Never> in
                    promise(.failure(.unknownError(err)))
                    return .init()
                }
                .sink { promise(.success($0)) }
                .store(in: &subscriptions)
        }
    }
    public static func getLists(boardId id: String) -> Future<[TRList], TRError> {
        Future<[TRList], TRError> { promise in
            if token == "token" || key == "key" {
                return promise(.failure(.noTokenOrAPIKey))
            }
            (get(url: "https://api.trello.com/1/boards/\(id)/lists?key=\(key)&token=\(token)") as AnyPublisher<[TRList], TRError>)
                .catch { err -> Empty<[TRList], Never> in
                    promise(.failure(.unknownError(err)))
                    return .init()
                }
                .sink { promise(.success($0)) }
                .store(in: &subscriptions)
        }
    }
    public static func getCards(boardId id: String) -> Future<[TRCard], TRError> {
        Future<[TRCard], TRError> { promise in
            if token == "token" || key == "key" {
                return promise(.failure(.noTokenOrAPIKey))
            }
            
            (get(url: "https://api.trello.com/1/boards/\(id)/cards?key=\(key)&token=\(token)") as AnyPublisher<[TRCard], TRError>)
                .catch { err -> Empty<[TRCard], Never> in
                    promise(.failure(.unknownError(err)))
                    return .init()
                }
                .sink { promise(.success($0)) }
                .store(in: &subscriptions)
        }
    }
    public static func getCards(listId id: String) -> Future<[TRCard], TRError> {
        Future<[TRCard], TRError> { promise in
            if token == "token" || key == "key" {
                return promise(.failure(.noTokenOrAPIKey))
            }
            
            (get(url: "https://api.trello.com/1/lists/\(id)/cards?key=\(key)&token=\(token)") as AnyPublisher<[TRCard], TRError>)
                .catch { err -> Empty<[TRCard], Never> in
                    promise(.failure(.unknownError(err)))
                    return .init()
                }
                .sink { promise(.success($0)) }
                .store(in: &subscriptions)
        }
    }
    
    private static func get<T: Decodable>(url: String) -> AnyPublisher<T, TRError> {
        Future<T, TRError> { promise in
            guard let url = URL(string: url) else {
                return promise(.failure(.unableToConstructURL))
            }
            URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                        throw TRError.wrongResponse
                    }
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .catch { err -> Empty<T, Never> in
                    promise(.failure(.unknownError(err)))
                    return .init()
                }
                .sink { promise(.success($0)) }
                .store(in: &subscriptions)
        }.eraseToAnyPublisher()
    }
    
    public static func getBoard(id: String) -> Future<TRBoard, TRError> {
        Future<TRBoard, TRError> { promise in
            if token == "token" || key == "key" {
                return promise(.failure(.noTokenOrAPIKey))
            }
            
            (get(url: "https://api.trello.com/1/boards/\(id)?key=\(key)&token=\(token)") as AnyPublisher<TRBoard, TRError>)
                .catch { err -> Empty<TRBoard, Never> in
                    promise(.failure(.unknownError(err)))
                    return .init()
                }
                .sink { promise(.success($0)) }
                .store(in: &subscriptions)
        }
    }
    public static func getList(id: String) -> Future<TRList, TRError> {
        Future<TRList, TRError> { promise in
            if token == "token" || key == "key" {
                return promise(.failure(.noTokenOrAPIKey))
            }
            
            (get(url: "https://api.trello.com/1/list/\(id)?key=\(key)&token=\(token)") as AnyPublisher<TRList, TRError>)
                .catch { err -> Empty<TRList, Never> in
                    promise(.failure(.unknownError(err)))
                    return .init()
                }
                .sink { promise(.success($0)) }
                .store(in: &subscriptions)
        }
    }
}

public struct TRBoard: Hashable, Codable {
    public var name: String
    public var id: String
    public var starred: Bool
    
    @inlinable
    public func getCards() -> Future<[TRCard], TRError> {
        Trellio.getCards(boardId: id)
    }
    @inlinable
    public func getLists() -> Future<[TRList], TRError> {
        Trellio.getLists(boardId: id)
    }
}

public struct TRList: Hashable, Codable {
    public var name: String
    public var id: String
    public var idBoard: String
    public var closed: Bool
    
    @inlinable
    public func getCards() -> Future<[TRCard], TRError> {
        Trellio.getCards(listId: id)
    }
    
    @inlinable
    public func getBoard() -> Future<TRBoard, TRError> {
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
    public func getBoard() -> Future<TRBoard, TRError> {
        Trellio.getBoard(id: idBoard)
    }
    @inlinable
    public func getList() -> Future<TRList, TRError> {
        Trellio.getList(id: idList)
    }
}

public enum TRError: Error {
    case noTokenOrAPIKey,
         unableToConstructURL,
         wrongResponse,
         unknownError(Error)
}
