import SwiftUI
import PhotosUI
import CoreData

struct TransactionListView: View {
    var transactions: FetchedResults<Transaction>
    var onLongPress: (Transaction) -> Void
    var pressedTransactionId: UUID?
    var onDelete: (IndexSet) -> Void

    var body: some View {
        if transactions.isEmpty {
            VStack {
                Spacer()
                Text("History is empty")
                    .foregroundColor(.gray)
                    .font(.title2)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        } else {
            List {
                ForEach(transactions) { tx in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tx.note?.isEmpty == false ? tx.note! : "No note")
                                .font(.body)
                            Text(tx.date ?? Date(), style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Text(String(format: "%.2f", tx.amount))
                            .foregroundColor(tx.type == "Income" ? .green : .red)
                            .font(.body)
                    }
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(Color.white)
                    .contentShape(Rectangle())
                    .scaleEffect(pressedTransactionId == tx.id ? 0.96 : 1.0)
                    .onLongPressGesture(minimumDuration: 0.5) {
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.impactOccurred()
                        onLongPress(tx)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
                .onDelete(perform: onDelete)
            }
            .listStyle(.plain)
        }
    }
}


