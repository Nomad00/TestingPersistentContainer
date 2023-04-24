//
//  ItemListFeatureTests.swift
//  TestingPersistentContainerTests
//
//  Created by Michael Stanziano on 4/13/23.
//

import ComposableArchitecture
import _CoreDataDependency
import XCTest

@testable import TestingPersistentContainer

@MainActor
class ItemListFeatureTests: XCTestCase {
    func testBasics() async {
        let store = TestStore(
            initialState: ItemListFeature.State(),
            reducer: ItemListFeature()) {
                $0.persistentContainer = .default(
                    inMemory: true
                )
                .withPreviewData()
            }
        
 
        /// Skipping because `_CoreDataDependency` action is caught 🤔
        store.exhaustivity = .off(showSkippedAssertions: true)
        
        let task = await store.send(.task)
        
        // TODO: How to set this up?
//        let expectedItems: Item.FetchedResults = PersistentContainer.FetchRequest.Results(fetchedObjects:[])
        
        // TODO: Why isn't this an unexpected action?
//        await store.receive(.didLoadItems(expectedItems))
        
        await task.cancel()
    }
}
