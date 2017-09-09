import Foundation

// iOS Communications
// By: Zaid Rahawi
// Notifications

// MARK: - Protocols

public protocol Notifier {
    var address: String { get }
    associatedtype Notification: RawRepresentable where Notification.RawValue == String
}

public extension Notifier {
    
    // MARK: - Static Computed Properties
    
    private static func name(forAddress address: String, notification: Notification) -> NSNotification.Name {
        return NSNotification.Name(rawValue: "\(self).\(address).\(notification.rawValue)")
    }
    
    // MARK: - Static Function
    
    static func addObserver(_ observer: Any, forAddress address: String, notification: Notification, completion: @escaping (Foundation.Notification) -> Void) {
        let notificationName = name(forAddress: address, notification: notification)
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil, using: completion)
    }
    
    static func postNotification(_ notification: Notification, forAddress address: String, object: Any? = nil, userInfo: [String : Any]? = nil) {
        let notificationName = name(forAddress: address, notification: notification)
        NotificationCenter.default.post(name: notificationName, object: object, userInfo: userInfo)
    }
    
    static func removeObserver(_ observer: Any, forAddress address: String, notification: Notification, object: Any? = nil) {
        let notificationName = name(forAddress: address, notification: notification)
        NotificationCenter.default.removeObserver(observer, name: notificationName, object: object)
    }
    
    // MARK: - Instance Methods
    
    func addObserver(_ observer: Any, notification: Notification, completion: @escaping (Foundation.Notification) -> Void) {
        Self.addObserver(observer, forAddress: address, notification: notification, completion: completion)
    }
    
    func postNotification(_ notification: Notification, object: Any? = nil, userInfo: [String : Any]? = nil) {
        Self.postNotification(notification, forAddress: address, object: object, userInfo: userInfo)
    }
    
    func removeObserver(_ observer: Any, notification: Notification, object: Any? = nil) {
        Self.removeObserver(observer, forAddress: address, notification: notification, object: object)
    }
}

// MARK: - Example

protocol Plane {
    var model: String { get }
}

class Airbus: Plane, Notifier {
    let model: String
    
    var isOnAir: Bool = false
    
    init(model: String) {
        self.model = model
    }
    
    var address: String {
        return model
    }
    
    enum Notification: String {
        case didTakeOff
        case didLand
    }
    
    func takeOff() {
        isOnAir = true
        postNotification(.didTakeOff, object: self)
    }
    
    func land() {
        isOnAir = false
        postNotification(.didLand, object: self)
    }
}

class Airport {
    init(model: String) {
        addObserver(forModel: model)
    }
    
    init(models: String...) {
        models.forEach { (model) in
            addObserver(forModel: model)
        }
    }
    
    func addObserver(forModel model: String) {
        Airbus.addObserver(self, forAddress: model, notification: .didTakeOff, completion: handleTakeOff)
        Airbus.addObserver(self, forAddress: model, notification: .didLand, completion: handleLand)
    }
    
    func handleTakeOff(notification: Notification) {
        guard let plane = notification.object as? Plane else { return }
        print("Airport: \(plane.model) is taking off")
    }
    
    func handleLand(notification: Notification) {
        guard let plane = notification.object as? Plane else { return }
        print("Airport: \(plane.model) landed")
    }
}

let a380 = Airbus(model: "A380")
let a350 = Airbus(model: "A350")

let airport = Airport(models: "A380", "A350")

a380.takeOff()
a350.takeOff()
a380.land()
a350.land()
