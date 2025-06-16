import SwiftUI
import PhotosUI
import CoreData

struct TransactionListView: View {
    var transactions: FetchedResults<Transaction>
    var onLongPress: (Transaction) -> Void
    var pressedTransactionId: UUID?
    var onDelete: (IndexSet) -> Void

    @State private var selectedTransaction: Transaction?
    @State private var showEditSheet = false

    private var groupedTransactions: [DateComponents: [Transaction]] {
        Dictionary(grouping: transactions) { tx in
            Calendar.current.dateComponents([.year, .month], from: tx.date ?? Date())
        }
    }

    private func monthYearString(from components: DateComponents) -> String {
        let date = Calendar.current.date(from: components) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

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
                ForEach(groupedTransactions.keys.sorted {
                    guard let d1 = Calendar.current.date(from: $0),
                          let d2 = Calendar.current.date(from: $1) else { return false }
                    return d1 > d2
                }, id: \.self) { key in
                    Section(header: Text(monthYearString(from: key))
                        .font(.title3)
                        .fontWeight(.semibold)
                    ) {
                        ForEach(groupedTransactions[key] ?? []) { tx in
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
                            .background(Color(.systemBackground))
                            .contentShape(Rectangle())
                            .scaleEffect(pressedTransactionId == tx.id ? 0.96 : 1.0)
                            .onLongPressGesture(minimumDuration: 0.5, pressing: { _ in }) {
                                onLongPress(tx)
                            }
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .swipeActions(edge: .leading) {
                                Button {
                                    selectedTransaction = tx
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    if let index = transactions.firstIndex(of: tx) {
                                        onDelete(IndexSet(integer: index))
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .sheet(item: $selectedTransaction) { transaction in
                EditTransactionView(transaction: transaction)
            }
        }
    }
}
