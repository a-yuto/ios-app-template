//
//  ContentView.swift
//  ios-app-template
//
//  Created by araki on 2026/05/20.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        itemDetailView(item: item)
                    } label: {
                        Text(
                            item.timestamp,
                            format: Date.FormatStyle(date: .numeric, time: .standard)
                        )
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
                .font(.appBodyMedium)
                .foregroundStyle(Color.appSecondaryLabel)
        }
    }

    private func itemDetailView(item: Item) -> some View {
        VStack(spacing: Spacing.sm) {
            Text("Item at")
                .font(.appBodySmall)
                .foregroundStyle(Color.appSecondaryLabel)
            Text(
                item.timestamp,
                format: Date.FormatStyle(date: .numeric, time: .standard)
            )
            .font(.appHeadlineMedium)
            .foregroundStyle(Color.appLabel)
        }
        .padding(Spacing.lg)
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
