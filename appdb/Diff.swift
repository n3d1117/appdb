import Foundation

/// A match between to collection
public struct DiffMatch: Hashable, CustomDebugStringConvertible {
    public typealias Index = IndexSet.Element
    /// Matching objects are not equal, but they have changed (see Matchable protocol)
    public let changed: Bool
    /// Source index
    public let from: Index
    /// Destination index
    public let to: Index
    
    public init(changed: Bool, from: Index, to: Index) {
        self.changed = changed
        self.from = from
        self.to = to
    }
    
    /// Initialize a match without change
    ///
    /// - Parameters:
    ///   - from: Source index
    ///   - to: Destination index
    public init(_ from: Index, _ to: Index) {
        self.changed = false
        self.from = from
        self.to = to
    }
    
    /// Initialize a match without change, which starts and finishes at same index
    ///
    /// - Parameter fromAndTo: Source and destination index
    public init(_ fromAndTo: Index) {
        self.changed = false
        self.from = fromAndTo
        self.to = fromAndTo
    }
    
    public var hashValue: Int {
        return 1575 ^ changed.hashValue ^ from.hashValue ^ to.hashValue
    }
    
    public static func ==(lhs: DiffMatch, rhs: DiffMatch) -> Bool {
        return lhs.changed == rhs.changed && lhs.from == rhs.from && lhs.to == rhs.to
    }
    
    public var debugDescription: String {
        let symbol = changed ? "🔄" : "✅"
        return "\(symbol) \(from) -> \(to)"
    }
}

/// Diff between two collections
public struct Diff<T: Collection> where T.Index == DiffMatch.Index, T.IndexDistance == DiffMatch.Index
{
    /// Inserted indexes in destination
    public let inserted: IndexSet
    /// Deleted indexes in source
    public let deleted: IndexSet
    /// Matches between source and destination
    public let matches: Set<DiffMatch>
    /// Matches which represent movements
    public let movements: Set<DiffMatch>
    
    public init(from source: T, to destination: T) {
        if source.count == 0 && destination.count > 0 { // Everything added
            self.inserted = IndexSet(integersIn: 0..<destination.count)
            self.deleted = IndexSet()
            self.matches = Set<DiffMatch>()
            self.movements = Set<DiffMatch>()
            return
        }
        
        if source.count > 0 && destination.count == 0 { // Everything deleted
            self.inserted = IndexSet()
            self.deleted = IndexSet(integersIn: 0..<source.count)
            self.matches = Set<DiffMatch>()
            self.movements = Set<DiffMatch>()
            return
        }
        
        // Make normal calculations
        var availableDestinationIndexes = IndexSet(integersIn: 0..<destination.count)
        var matches = [DiffMatch]()
        var deleted = IndexSet()
        
        // Scan match from source to destination
        for (sourceIndex, sourceElement) in source.enumerated() {
            if let match = Diff.match(for: sourceElement, at: sourceIndex, in: destination, using: availableDestinationIndexes)
            {
                availableDestinationIndexes.remove(match.to)
                matches.append(match)
            }
            else {
                deleted.insert(sourceIndex)
            }
        } // for source
        
        // Every index without a match from source is an inserted index
        self.inserted = availableDestinationIndexes
        availableDestinationIndexes.removeAll()
        
        // Find movements inside positive matches
        self.movements = Diff.movements(in: matches, with: inserted, deleted)
        
        self.deleted = deleted
        self.matches = Set(matches)
    } // init

    private static func match(for element: Any, at index: T.Index, in destination: T, using availableDestinationIndexes: IndexSet) -> DiffMatch?
    {
        guard let element = element as? Matchable else {
            return nil
        }
        
        for (destinationIndex, destinationElement) in destination.enumerated() where availableDestinationIndexes.contains(destinationIndex)
        {
            switch element.match(with: destinationElement)
            {
            case .equal:
                return DiffMatch(changed: false, from: index, to: destinationIndex)
            case .change:
                return DiffMatch(changed: true, from: index, to: destinationIndex)
            case .none:
                break
            } // switch
        } // for destination
        
        return nil
    }

    private static func movements(in matches: [DiffMatch], with inserted: IndexSet, _ deleted: IndexSet) -> Set<DiffMatch>
    {
        var movements = [DiffMatch]()
        
        for match in matches {
            if match.from != match.to {
                let offset = sourceOffset(for: match, in: movements, with: inserted, deleted)
                if match.from + offset != match.to {
                    movements.append(match)
                }
            } // if
        } // for
        
        return Set(movements)
    }
    
    private static func sourceOffset(for movement: DiffMatch, in movements: [DiffMatch], with inserted: IndexSet, _ deleted: IndexSet) -> Int
    {
        let insertionsBefore = inserted.count(in: 0..<movement.to)
        let deletionsBefore = deleted.count(in: 0..<movement.from)
        
        var offset = insertionsBefore - deletionsBefore
        for anotherMovement in movements {
            if movement != anotherMovement && anotherMovement.from < movement.from && anotherMovement.to > movement.to
            {
                offset = offset - 1 // A preceding item is now after
            } // if
            
            // Movements with anotherMovement.source > movement.source are discarded
            // because they are considered future movements
        } // for
        
        return offset
    }
}

public extension Diff {
    /// Utility method to pack diff with source and destination collections
    ///
    /// - Parameters:
    ///   - source: Source collection
    ///   - destination: Destination collection
    /// - Returns: A tuple with source, destination and computed diff
    public static func between(_ source: T, _ destination: T) -> (source: T, destination: T, diff: Diff<T>)
    {
        return (source: source, destination: destination, diff: Diff(from: source, to: destination))
    }
}
