//
//  Configuration.swift
//  
//
//  Created by Anna Münster on 22.09.22.
//

import Foundation

public struct Configuration {
    public var allowAnonymousUsers = true
    public var userRepository: UserRepositoryProtocol? = nil
    
    public init() { }
}
