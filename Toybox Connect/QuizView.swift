import SwiftUI
import SwiftData

struct QuizAnswer: Identifiable, Codable {
    var id = UUID()
    var title: String
    var question: String
    var answer: Bool?
}

struct SwipeableQuizCard: View {
    @Binding var answer: QuizAnswer
    @State private var offset: CGFloat = 0
    private let swipeThreshold: CGFloat = 100
    
    var body: some View {
        HStack {
            Button {
                answer.answer = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(answer.answer ?? true ? .gray.opacity(0.3) : .red)
            }
            HStack {
                VStack(alignment: .leading) {
                    Text(answer.title)
                        .foregroundColor(.primary.opacity(0.8))
                        .fontWeight(.medium)
                    Text(answer.question)
                        .foregroundColor(.primary.opacity(0.4))
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(15)
            .background(cardBackground)
            .cornerRadius(10)
            .offset(x: offset)
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation.width
                    }
                    .onEnded { _ in
                        withAnimation {
                            if offset > swipeThreshold {
                                offset = 0
                                answer.answer = true
                            } else if offset < -swipeThreshold {
                                offset = 0
                                answer.answer = false
                            } else {
                                offset = 0
                            }
                        }
                    }
            )
            Button {
                answer.answer = true
            } label: {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title)
                    .foregroundColor(answer.answer ?? false ? .green : .gray.opacity(0.3))
            }
        }
    }
    
    private var cardBackground: Color {
        if let passed = answer.answer {
            return passed ? Color.green.opacity(0.1) : Color.red.opacity(0.1)
        } else {
            return Color(.secondarySystemGroupedBackground)
        }
    }
}

struct QuizView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var quizAnswers: [QuizAnswer] = [
        QuizAnswer(title: "Pets", question: "Do you prefer cats over dogs?"),
        QuizAnswer(title: "Debates", question: "Do you enjoy debates?"),
        QuizAnswer(title: "Waking up", question: "Are you a morning person?"),
        QuizAnswer(title: "Pizza", question: "Do you like pineapple on pizza?")
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .opacity(0.7)
                    VStack(alignment: .leading) {
                        Text("Answer and get an instant match")
                            .fontWeight(.semibold)
                        Text("Our algortihm will find your perfect opposite to meet.")
                    }
                    Spacer()
                        
                }
                .padding(12)
                .background(.secondary.opacity(0.2))
                .foregroundStyle(.secondary)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                Text("Let's get to know you")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.vertical, 3)
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach($quizAnswers) { $answer in
                            SwipeableQuizCard(answer: $answer)
                        }
                    }
                }
                NavigationLink("Submit") {
                    SplashView()
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(.accent)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
            }
            .padding(15)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Incompatibility quiz")
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(name: "Darren Candra", timestamp: Date(), friendship: 5, answers: quizAnswers)
            modelContext.insert(newItem)
        }
    }
}

#Preview {
    QuizView()
        .modelContainer(for: Item.self, inMemory: true)
}
