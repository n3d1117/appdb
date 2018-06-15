import Foundation

/// How two objects match
///
/// - none: No match
/// - change: Partial match (same object has changed)
/// - equal: Complete match
public enum Match: String, CustomDebugStringConvertible {
    case none = "❌"
    case change = "🔄"
    case equal = "✅"
    
    public var debugDescription: String {
        return self.rawValue
    }
}

/// The way two objects are compared to spot no match, partial match or complete match
public protocol Matchable {
    func match(with object: Any) -> Match
}

public extension Matchable where Self: Equatable {
    public func match(with object: Any) -> Match {
        if let object = object as? Self {
            return self == object ? .equal : .none
        }
        
        return .none
    }
}

public extension Equatable where Self: Matchable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.match(with: rhs) == .equal
    }
}
