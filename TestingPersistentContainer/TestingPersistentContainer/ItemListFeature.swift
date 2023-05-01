//
//  ItemListFeature.swift
//  TestingPersistentContainer
//
//  Created by Michael Stanziano on 4/13/23.
//

import ComposableArchitecture
import DependenciesAdditions
import _CoreDataDependency
import SFSafeSymbols
import SwiftUI

#if DEBUG
import CoreData
#endif

struct ItemListFeature: Reducer {
    @Dependency(\.persistentContainer)
    var persistentContainer
    
    struct State: Equatable {
        var items: Item.FetchedResults = .empty
    }
    
    enum Action: Equatable {
        case task
        case didLoadItems(Item.FetchedResults)
        case addItemTapped
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
            // When the view appears, start the effect that updates the Fetch Request.
        case .task:
            return .run { send in
                for try await items in await self.persistentContainer.request(
                    Item.self,
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \Item.name, ascending: true)
                    ]
                ) {
                    await send(.didLoadItems(items)) // TODO: Need animation?
                }
            }
        case let .didLoadItems(items):
            print(".didLoadItems\(items)")
            state.items = items
            return .none
        case .addItemTapped:
#if DEBUG
            return .run { @MainActor _ in
                /// - note: Temporary while trying to get reacting to changes working.
                /// Will have a dedicated UI.
                _ = persistentContainer.with { context in
                    let entity = NSEntityDescription.entity(
                        forEntityName: "Item", in: context
                    )!
                    let newItem = Item(entity: entity, insertInto: context)
                    let sampleItemName = PersistentContainer.sampleItems.randomElement()
                    newItem.name = sampleItemName
                    
                    try! context.save()
                }
            }
#else
            return .none
#endif
        }
    }
}

struct ItemListView: View {
    let store: StoreOf<ItemListFeature>
    
    var body: some View {
        // TODO: Deal with empty state
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    ForEach(viewStore.items) { item in
                        Text(item.wrappedName)
                    }
                }
                .navigationTitle("Items")
                .toolbar {
                    ToolbarItem(
                        placement: .navigationBarTrailing
                    ) {
                        Button(action: { viewStore.send(.addItemTapped) } ) {
                            Label("Add Item", systemSymbol: .plus)
                        }
                    }
                }
                .task {
                    await viewStore.send(.task).finish()
                }
            }
        }
    }
}

#if DEBUG
extension PersistentContainer {
    static let sampleItems = ["Apples", "Milk", "Cereal", "Coffee", "Carrots", "Oregano", "Napkins", "Trash bags", "Dark Chocolate Chunks", "Bacon"]
    
    @MainActor
    func withPreviewData()  -> Self {
        with { context in
            for sampleItem in Self.sampleItems {
                let entity = NSEntityDescription.entity(
                    forEntityName: "Item", in: context
                )!
                let newItem = Item(entity: entity, insertInto: context)
                newItem.name = sampleItem
            }
            
            try! context.save()
        }
    }
}

struct ItemListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListView(
            store: .init(
                initialState: ItemListFeature.State(),
                reducer: ItemListFeature(),
                prepareDependencies: {
                    $0.persistentContainer = .default(inMemory: true).withPreviewData()
                }
            )
        )
    }
}
#endif
