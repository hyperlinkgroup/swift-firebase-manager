//
//  FirestoreFilter.swift
//  
//
//  Created by Anna Münster on 14.02.23.
//

import Firebase

public struct FirestoreFilter {
    public enum ComparisonOperator {
        case equal, notEqual, greaterThan, greaterThanOrEqual, lessThan, lessThanOrEqual
    }
    
    public init(key: String, comparisonOperator: ComparisonOperator, value: Any) {
        self.key = key
        self.comparisonOperator = comparisonOperator
        self.value = value
    }
    
    public var key: String
    public var comparisonOperator: ComparisonOperator
    public var value: Any
    
    func addFilter(_ query: Query) -> Query {
        switch comparisonOperator {
        case .equal:
            return query.whereField(key, isEqualTo: value)
        case .notEqual:
            return query.whereField(key, isNotEqualTo: value)
        case .greaterThan:
            return query.whereField(key, isGreaterThan: value)
        case .greaterThanOrEqual:
            return query.whereField(key, isGreaterThanOrEqualTo: value)
        case .lessThan:
            return query.whereField(key, isLessThan: value)
        case .lessThanOrEqual:
            return query.whereField(key, isLessThanOrEqualTo: value)
        }
    }
}
