//
//  TestingPersistentContainerApp.swift
//  TestingPersistentContainer
//
//  Created by Michael Stanziano on 4/23/23.
//

import ComposableArchitecture
import SwiftUI

@main
struct TestingPersistentContainerApp: App {
    
    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                ItemListView(
                    store: .init(
                        initialState: ItemListFeature.State(),
                        reducer: ItemListFeature()) {
                            $0.persistentContainer = .default()
                        }
                )
            }
        }
    }
}
