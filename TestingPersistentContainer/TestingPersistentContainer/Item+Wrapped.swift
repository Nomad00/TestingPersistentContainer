//
//  Item+Wrapped.swift
//  TestingPersistentContainer
//
//  Created by Michael Stanziano on 4/21/22.
//

import Foundation

extension Item {
    public var wrappedName: String {
        name ?? ""
    }
}
