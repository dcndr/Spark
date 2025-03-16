//
//  ContentView.swift
//  Toybox Connect
//
//  Created by Darren Candra on 15/3/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        TabView {
            MeetView()
                .tabItem {
                    Label("Meet", systemImage: "person.2.fill")
                }
            FriendsView()
                .tabItem {
                    Label("About", systemImage: "bubble.fill")
                }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(name: "Darren Candra", timestamp: Date(), friendship: 5)
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
