import Foundation
import Combine

// 1
/* Helper Function */
public func example(of title: String, action: () -> Void) {
    print("\n——— Example of:", title,"———")
    action()
}

example(of: "Publisher") {
    // 2
    let myNotification = Notification.Name("MyNotification")
    // 3
    let center = NotificationCenter.default
    // 4
    let publisher = center.publisher(for: myNotification, object: nil)

    /*
     OUTPUT:
     ——— Example of Publisher ———
     */
}

example(of: "Subscriber") {
    // 1
    let myNotification = Notification.Name("MyNotification")
    let center = NotificationCenter.default
    let publisher = center.publisher(for: myNotification, object: nil)
    // 2
    let subscription = publisher.sink { _ in
        print("Notification received from a publisher")
    }
    // 3
    center.post(name: myNotification, object: nil)
    // 4
    subscription.cancel()

    /*
     OUTPUT:
     ——— Example of Subscriber ———
     Notification received from a publisher
     */
}

example(of: "Operator") {
    // 1
    let numbersPublisher = [1, 2, 3].publisher
    // 2
    let squaredNumbersPublisher = numbersPublisher.map { $0 * $0 }
    // 3
    let cancellable = squaredNumbersPublisher.sink { squaredNumber in
        print("Squared Number: \(squaredNumber)")
    }

    /* OUTPUT:
     ——— Example of Operator ———
     Squared Number: 1
     Squared Number: 4
     Squared Number: 9
     */
}
