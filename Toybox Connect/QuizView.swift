import SwiftUI
import SwiftData

struct MeetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var alternateText = "great friends"
    private let texts = ["who gets you", "your next buddy"]
    @State private var timer: Timer?
    var body: some View {
        NavigationSplitView {
            VStack(alignment: .center) {
                Image("PhotoCards")
                    .resizable()
                    .frame(width: 290, height: 220)

                HStack(spacing: 5) {
                    Text("Meet")
                    Text(alternateText)
                        .fontWeight(.bold)
                    Text("on Spark")
                }
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.vertical, 3)
                .onAppear {
                    timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                        withAnimation {
                            alternateText = texts.first(where: { $0 != alternateText }) ?? texts[0]
                        }
                    }
                }
                .onDisappear {
                    timer?.invalidate()
                    timer = nil
                }

                Text("Every good friendship starts with a spark.\nThe best way to get one? A fire; arguments and disagreements.")
                    .opacity(0.7)
                Text("We match you with those you disagree with to build lasting friendships.")
                    .opacity(0.9)
                    .fontWeight(.medium)
                
                NavigationLink {
                    QuizView()
                } label: {
                    HStack {
                        Text("Find friends with the incompatibility quiz")
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
            .navigationTitle("Meet")
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
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
