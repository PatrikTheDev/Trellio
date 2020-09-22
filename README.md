# Trellio

A very simple library to load Trello boards, lists and cards via the [Trello REST API](https://developer.atlassian.com/cloud/trello/rest/).

## Usage
### Setup
```swift
Trellio.key = "Trello API Key"
Trellio.token = "User token"
```
_Note: if either the key or token isn't set, Trellio will fail with `TRError.noTokenOrAPIKey` on every request._

### Boards
```swift
Trellio.getBoards() // AnyPublisher<[TRBoard], TRError>
board.getLists() // AnyPublisher<[TRList], TRError>
board.getCards() // AnyPublisher<[TRCard], TRError>
```
### Lists
```swift
list.getBoard() // AnyPublisher<TRBoard, TRError>
list.getCards() // AnyPublisher<[TRCard], TRError>
```
### Cards
```swift
card.getList() // AnyPublisher<TRList, TRError>
card.getBoard() // AnyPublisher<TRBoard, TRError>
```
## Error handling
`TRError` is an `enum` with multiple cases:
* `noTokenOrAPIKey`: You forgot to set the API key or token.
* `unableToConstructURL`: Strange error, check the API key, token or id (if applicable).
* `wrongResponse(HTTPURLResponse)`: The response code was wrong.
* `noResponse`: Response cast to HTTPURLResponse failed, please file an issue.
* `unknownError(Error)`: Self explanatory, has the error attached.

## Testing
This project has unit tests, please run them before making a pull request. To run them, make a `Secrets` object with two static variables:
```swift
static var key = "key"
static var token = "token"
```
Please do not commit this file.

## Dependencies
* [PTDList](https://github.com/Patrik-svobodik/PTDList)
* [Cartography](https://github.com/robb/Cartography)
