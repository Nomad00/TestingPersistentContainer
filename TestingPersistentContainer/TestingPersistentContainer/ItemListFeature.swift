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
                    await send(.didLoadItems(items))
                }
            }
        case let .didLoadItems(items):
            print(".didLoadItems\(items)")
            state.items = items
            return .none
        case .addItemTapped:
            // TODO: Insert a prebuilt `Item`.
            return .none
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
                let newItem = Item(context: context)
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
