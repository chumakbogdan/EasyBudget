import SwiftUI
import PhotosUI
import CoreData

struct TransactionDetailOverlay: View {
    var transaction: Transaction
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Transaction Details")
                .font(.title)
                .bold()

            HStack{
                HStack {
                    Text("Category:")
                        .bold()
                        .foregroundColor(.black)
                    Text(transaction.toCategory?.name ?? "None")
                }
                HStack {
                    Text("Date:")
                        .bold()
                        .foregroundColor(.black)
                    Text(transaction.date ?? Date(), style: .date)
                }
            }
            HStack{
                HStack {
                    Text("Amount:")
                        .bold()
                        .foregroundColor(.black)
                    Text("\(transaction.amount, specifier: "%.2f")")
                }
                HStack {
                    Text("Type:")
                        .bold()
                        .foregroundColor(.black)
                    Text(transaction.type ?? "")
                        .foregroundColor((transaction.type ?? "") == "Income" ? .green : .red)
                }
            }

            HStack(alignment: .top) {
                Text("Note:")
                    .bold()
                    .foregroundColor(.black)
                Text(transaction.note ?? "-")
            }

            Button("Close", action: onClose)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding()
        .transition(.scale)
    }
}
