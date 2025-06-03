import SwiftUI
import CoreData

struct DashboardView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<Transaction>
    
    var totalIncome: Float {
        transactions.filter { $0.type == "Income" }.map { $0.amount }.reduce(0, +)
    }

    var totalExpenses: Float {
        transactions.filter { $0.type == "Expenses" }.map { $0.amount }.reduce(0, +)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Balance: \(totalIncome - totalExpenses, specifier: "%.2f")")
                    .font(.largeTitle)
                    .onLongPressGesture {
                        // Gest – długi nacisk pokazuje wykres (placeholder)
                        print("Show chart")
                    }

                HStack {
                    VStack {
                        Text("Income")
                        Text("\(totalIncome, specifier: "%.2f")")
                    }.padding().background(Color.green.opacity(0.2)).cornerRadius(10)

                    VStack {
                        Text("Expenses")
                        Text("\(totalExpenses, specifier: "%.2f")")
                    }.padding().background(Color.red.opacity(0.2)).cornerRadius(10)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Dashboard")
        }
    }
}
