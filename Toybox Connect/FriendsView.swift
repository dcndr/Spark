//
//  MeetView.swift
//  Toybox Connect
//
//  Created by Darren Candra on 16/3/2025.
//

import SwiftUI
import SwiftData

struct MeetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
            NavigationSplitView {
                VStack(alignment: .center) {
                    Image("PhotoCards")
                        .resizable()
                        .frame(width: 290, height: 220)
                    Text("Meet new friends with Flame")
                        .fontWeight(.bold)
                        .font(.title3)
                        .padding(.vertical, 2)
                    Text("Every good friendship starts with a spark.\nThe best way to get one? A flame; arguments, and disagreements.")
                        .opacity(0.7)
                    Text("We match you with those you disagree with to build lasting friendships.")
                        .opacity(0.9)
                        .fontWeight(.medium)
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
                .multilineTextAlignment(.center)
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
                .foregroundStyle(.primary.opacity(0.7))
                .navigationTitle("Flame")
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
