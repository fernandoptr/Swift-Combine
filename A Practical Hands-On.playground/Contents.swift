import Foundation
import UIKit
import Combine

// 1
/* Helper Function */
public func example(of title: String, action: () -> Void) {
    print("\n——— Example of:", title,"———")
    action()
}

example(of: "Publishers") {
    // 2
    let justPublisher = Just([1, 2, 3, 4, 5])
    // 3
    let sequencePublisher = [1, 2, 3, 4, 5].publisher
    // 4
    let emptyPublisher = Empty<Int, Never>()

    /*
     OUTPUT:
     ——— Example of Publishers ———
     */
}

example(of: "Subscribing with sink") {
    // 1
    let justPublisher = Just([1, 2, 3])
    let sequencePublisher = [1, 2, 3].publisher
    let emptyPublisher = Empty<Int, Never>()

    // 2
    let justSubscription = justPublisher.sink { value in
        print("Just Publisher emitted: \(value)")
    }
    let sequenceSubscription = sequencePublisher.sink { values in
        print("Sequence Publisher emitted values: \(values)")
    }
    let emptySubscription = emptyPublisher.sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Empty Publisher completed successfully")
            case .failure(let error):
                print("Empty Publisher completed with error: \(error)")
            }
        },
        receiveValue: { _ in }
    )

    /*
     OUTPUT:
     ——— Example of Subscribing with sink ———
     Just Publisher emitted: [1, 2, 3]
     Sequence Publisher emitted values: 1
     Sequence Publisher emitted values: 2
     Sequence Publisher emitted values: 3
     Empty Publisher completed successfully
     */
}

example(of: "Subscribing with assign(to:on:)") {
    // 1
    class MyClass {
        var value: String = "" {
            didSet {
                print(value)
            }
        }
    }
    // 2
    let myClass = MyClass()
    // 3
    let publisher = ["Hello","world!"].publisher
    // 4
    _ = publisher
        .assign(to: \.value, on: myClass)

    /*
     OUTPUT:
     ——— Example of Subscribing with assign(to:on) ———
     Hello
     world!
     */
}

example(of: "Subscribing with assign(to:)") {
    // 1
    class MyClass {
        @Published var republishedValue: Int = 1
    }
    let myClass = MyClass()
    // 2
    (2..<4).publisher
        .assign(to: &myClass.$republishedValue)

    /*
     OUTPUT:
     ——— Example of Subscribing with assign(to:) ———
     */
}

example(of: "Manual cancellation") {
    // 1
    let subscription = Just(1).sink { value in
        print("Just Publisher emitted: \(value)")
    }
    // 2
    subscription.cancel()
}

example(of: "Automatic cancellation") {
    class MyClass {
        // 1
        var cancellables: Set<AnyCancellable> = []
        // 2
        init() {
            Just("Hello")
                .sink { _ in }
                .store(in: &cancellables)
            [1,2,3].publisher
                .sink { _ in }
                .store(in: &cancellables)
        }
    }
}

example(of: "collect(int) operator") {
    ["A", "B", "C", "D", "E", "F", "G"].publisher
        .collect(2)
        .sink { print($0) }
}

example(of: "map(_:) operator") {
    ["A", "B", "C", "D"].publisher
        .map { "\($0)\($0)" }
        .sink { print($0) }
}

example(of: "tryMap(_:) operator") {
    enum MyError: Error {
        case invalidConversion
    }
    ["1", "2", "three"].publisher
        .tryMap { str in
            guard let value = Int(str) else { throw MyError.invalidConversion }
            return value
        }
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })

    /*
     OUTPUT:
     ——— Example of: tryMap(_:) operator ———
     1
     2
     failure(__lldb_expr_75.(unknown context at $100d185dc).(unknown context at $100d18734).(unknown context at $100d1873c).MyError.invalidConversion)
     */
}

example(of: "flatMap(maxPublishers:_:) operator") {
    let publisher = ["apple", "banana", "orange"].publisher

    _ = publisher
        .flatMap { fruit in
            Just(fruit.uppercased())
        }
        .sink(receiveValue: { print($0) })

    /*
     OUTPUT:
     ——— Example of: flatMap(maxPublishers:_:) operator ———
     APPLE
     BANANA
     ORANGE
     */
}

example(of: "replaceNil(with:) operator") {
    [1, nil, 3].publisher
        .replaceNil(with: 2)
        .sink { print($0) }

    /*
     OUTPUT:
     ——— Example of: replaceNil(with:) operator ———
     Optional(1)
     Optional(2)
     Optional(3)
     */
}

example(of: "ReplaceEmpty(with:) operator") {
    Empty<Int, Never>()
        .replaceEmpty(with: 1)
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })

    /*
     OUTPUT:
     ——— Example of: ReplaceEmpty(with:) operator ———
     1
     finished
     */
}

example(of: "Scan(_:_:) operator") {
    [1, 2, 3, 4].publisher
        .scan(0) { $0 + $1 }
        .sink { print($0) }
}

example(of: "filter(_:) operator") {
    [1, 2, 3, 4].publisher
        .filter { $0 > 3 }
        .sink { print($0) }
}

example(of: "compactMap(_:) operator") {
    [1, 2, 3, 4].publisher
        .compactMap { $0 % 2 == 0 ? nil : "e" }
        .sink { print($0) }
}

example(of: "first(where:) operator") {
    [1, 2, 3, 4].publisher
        .first(where: { $0 > 3 } )
        .sink { print($0) }
}

example(of: "last(where:) operator") {
    [1, 2, 3, 4].publisher
        .last(where: { $0 > 3 } )
        .sink { print($0) }
}

example(of: "drop(untilOutputFrom:)") {
    let first = PassthroughSubject<String, Never>()
    let second = PassthroughSubject<Int, Never>()
    first
        .drop(untilOutputFrom: second)
        .sink { print($0) }

    ["A", "B", "C", "D"].forEach { i in
        first.send(i)
        if i == "B" {
            second.send(1)
        }
    }
}

example(of: "prefix(untilOutputFrom:)") {
    let first = PassthroughSubject<String, Never>()
    let second = PassthroughSubject<Int, Never>()
    first
        .prefix(untilOutputFrom: second)
        .sink { print($0) }

    ["A", "B", "C", "D"].forEach { i in
        first.send(i)
        if i == "B" {
            second.send(1)
        }
    }
}

example(of: "prepend([ublisher:)") {
    let first = ["A", "B", "C", "D"].publisher
    let second = ["1", "2"].publisher
    first
        .prepend(second)
        .sink { print($0) }
}

example(of: "append(publisher:)") {
    let first = ["A", "B", "C", "D"].publisher
    let second = ["1", "2"].publisher
    first
        .append(second)
        .sink { print($0) }
}

example(of: "switchToLatest()") {
    let publisher = PassthroughSubject<PassthroughSubject<String, Never>, Never>()
    let first = PassthroughSubject<String, Never>()
    let second = PassthroughSubject<String, Never>()
    publisher
        .switchToLatest()
        .sink { print($0) }

    publisher.send(first)
    first.send("A")
    publisher.send(second)
    first.send("B")
    second.send("1")
    second.send("2")

    /*
     OUTPUT:
     ——— Example of: switchToLatest() ———
     A
     1
     2
     */
}

example(of: "merge(with:)") {
    let first = PassthroughSubject<String, Never>()
    let second = PassthroughSubject<String, Never>()

    first
        .merge(with: second)
        .sink { print($0) }

    ["A", "B", "C", "D", "E", "F"].forEach { i in
        first.send(i)
        if i == "B" {
            second.send("1")
        }
    }
    second.send("2")
}

example(of: "combineLatest()") {
    let first = PassthroughSubject<String, Never>()
    let second = PassthroughSubject<Int, Never>()

    first
        .combineLatest(second)
        .sink { print($0) }

    first.send("A")
    first.send("B")
    second.send(1)
}

example(of: "zip()") {
    let first = PassthroughSubject<String, Never>()
    let second = PassthroughSubject<Int, Never>()

    first
        .zip(second)
        .sink { print($0) }

    first.send("A")
    second.send(1)
    first.send("B")
    second.send(2)
}

example(of: "PassthroughSubject") {
    // 1
    let subject = PassthroughSubject<String, Never>()
    // 2
    subject
        .sink { print($0) }
    // 3
    subject.send("Hello")

    /*
     OUTPUT:
     ——— Example of: PassthroughSubject ———
     Hello
     */
}


example(of: "CurrentValueSubject") {
    // 1
    let subject = CurrentValueSubject<Int, Never>(1)
    // 2
    subject
        .sink { print($0) }
    // 3
    subject.send(2)
    subject.send(3)
    // 4
    print("Current value: \(subject.value)")
    // 5
    subject.value = 4
    // 6
    subject
        .sink { print("Second subscription: \($0)") }

    /*
     OUTPUT:
     ——— Example of: CurrentValueSubject ———
     1
     2
     3
     Current value: 3
     4
     Second subscription: 4
     */
}

print("\n——— Example of: Network Request ———")
// 1
struct User: Codable {
    let id: Int
    let name: String
    let username: String
    let email: String
}
struct Post: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
struct PostDetail {
    let userId: Int
    let postId: Int
    let title: String
    let body: String
    let username: String
}

// 2
func fetchUsers() -> AnyPublisher<[User], Error> {
    let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
    return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: [User].self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}
func fetchPosts() -> AnyPublisher<[Post], Error> {
    let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
    return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: [Post].self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}

// 3
let queryInput = PassthroughSubject<String, Error>()
var subscribers: Set<AnyCancellable> = []
var filteredPosts: [PostDetail] = []

// 4
queryInput
    .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
// 5
    .combineLatest(fetchUsers(), fetchPosts())
    .map { query, users, posts in
        // 6
        return posts
            .filter { post in
                post.title.lowercased().contains(query.lowercased())
            }
            .compactMap { post in
                guard let user = users.first(where: { $0.id == post.userId }) else {
                    return nil
                }
                return PostDetail(userId: user.id, postId: post.id, title: post.title, body: post.body, username: user.username)
            }
    }
    .sink { completion in
        // 7
        switch completion {
        case .finished:
            print("Update UI - Completion")
        case .failure(let error):
            print(error)
        }
    } receiveValue: { posts in
        // 8
        filteredPosts = posts
        print("Filtered Posts: $\(filteredPosts)\n")
    }
    .store(in: &subscribers)

// 9
queryInput.send("repellat")
queryInput.send("possim")
DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
    queryInput.send("possimus")
}
DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    queryInput.send("occaecati")
}

