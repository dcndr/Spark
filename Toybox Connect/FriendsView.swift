//
//  MeetView.swift
//  Toybox Connect
//
//  Created by Darren Candra on 16/3/2025.
//

import SwiftUI
import SwiftData

struct FriendsView: View {
    @Environment(\.modelContext) private var modelContext
    @State var date = Date.now
    @Query private var items: [Item]

    var body: some View {
            NavigationSplitView {
                List {
                    Section {
                        ForEach(items) { item in
                            VStack(alignment: .leading) {
                                Text("Darren Candra")
                                    .fontWeight(.bold)
                                    .font(.title3)
                                    .padding(.vertical, 2)
                                Text(" \(date.formatted(date: .long, time: .standard))")
                                    .opacity(0.7)
                                Text("We match you with those you disagree with to build lasting friendships.")
                                    .opacity(0.9)
                                    .fontWeight(.medium)
                            }
                        }
                        Button {
                            
                        } label: {
                            HStack {
                                Text("Take the incompatibility quiz")
                                Image(systemName: "chevron.right")
                            }
                            .foregroundStyle(.accent)
                            .padding(.vertical, 5)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
                .foregroundStyle(.primary.opacity(0.7))
                .navigationTitle("Friends")
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
    FriendsView()
        .modelContainer(for: Item.self, inMemory: true)
}
