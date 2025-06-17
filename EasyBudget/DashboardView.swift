import SwiftUI
import CoreData

struct DashboardView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<Transaction>

    @State private var selectedMonth: DateComponents? = nil
    @State private var selectedCategory: String? = nil
    @State private var selectedType: String? = nil
    @State private var selectedTransaction: Transaction? = nil
    @State private var isShowingTransactionDetail = false
    @State private var pressedTransactionId: UUID? = nil

    var availableMonths: [DateComponents] {
        let unique = Set(transactions.map { Calendar.current.dateComponents([.year, .month], from: $0.date ?? Date()) })
        return Array(unique).sorted {
            guard let d1 = Calendar.current.date(from: $0),
                  let d2 = Calendar.current.date(from: $1) else { return false }
            return d1 > d2
        }
    }

    var availableCategories: [String] {
        Array(Set(transactions.compactMap { $0.toCategory?.name })).sorted()
    }

    var availableTypes: [String] {
        Array(Set(transactions.compactMap { $0.type })).sorted()
    }

    var filteredTransactions: [Transaction] {
        transactions.filter { tx in
            let txMonth = Calendar.current.dateComponents([.year, .month], from: tx.date ?? Date())
            let matchesMonth = selectedMonth == nil || selectedMonth == txMonth
            let matchesCategory = selectedCategory == nil || selectedCategory == tx.toCategory?.name
            let matchesType = selectedType == nil || selectedType == tx.type
            return matchesMonth && matchesCategory && matchesType
        }
    }

    var totalIncome: Float {
        filteredTransactions.filter { $0.type == "Income" }.map { $0.amount }.reduce(0, +)
    }

    var totalExpenses: Float {
        filteredTransactions.filter { $0.type == "Expenses" }.map { $0.amount }.reduce(0, +)
    }

    func monthYearString(from components: DateComponents) -> String {
        let date = Calendar.current.date(from: components) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack {
                    Text("Balance: \(totalIncome - totalExpenses, specifier: "%.2f")")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity)

                    HStack {
                        VStack {
                            Text("Income")
                            Text("\(totalIncome, specifier: "%.2f")")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.5))
                        .cornerRadius(10)

                        VStack {
                            Text("Expenses")
                            Text("\(totalExpenses, specifier: "%.2f")")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.5))
                        .cornerRadius(10)
                    }
                }

                HStack {
                    VStack {
                        Text("Month")
                        Picker("Month", selection: $selectedMonth) {
                            Text("All").tag(nil as DateComponents?)
                            ForEach(availableMonths, id: \.self) { comp in
                                Text(monthYearString(from: comp)).tag(Optional(comp))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .frame(maxWidth: .infinity)

                    VStack {
                        Text("Category")
                        Picker("Category", selection: $selectedCategory) {
                            Text("All").tag(nil as String?)
                            ForEach(availableCategories, id: \.self) { category in
                                Text(category).tag(Optional(category))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .frame(maxWidth: .infinity)

                    VStack {
                        Text("Type")
                        Picker("Type", selection: $selectedType) {
                            Text("All").tag(nil as String?)
                            ForEach(availableTypes, id: \.self) { type in
                                Text(type).tag(Optional(type))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .frame(maxWidth: .infinity)
                }

                TransactionListView(
                    transactions: filteredTransactions,
                    pressedTransactionId: $pressedTransactionId,
                    onLongPress: { tx in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTransaction = tx
                            pressedTransactionId = tx.id
                            isShowingTransactionDetail = true
                        }
                    },
                    onDelete: { indexSet in
                        let context = PersistenceController.shared.container.viewContext
                        for index in indexSet {
                            let tx = filteredTransactions[index]
                            context.delete(tx)
                        }
                        try? context.save()
                    }
                )
            }
            .padding()
            .navigationTitle("Dashboard")
            .alert(isPresented: $isShowingTransactionDetail) {
                Alert(
                    title: Text("Transaction Details"),
                    message: Text(transactionDetailText),
                    dismissButton: .default(Text("OK")) {
                        pressedTransactionId = nil
                        selectedTransaction = nil
                    }
                )
            }
        }
    }

    private var transactionDetailText: String {
        guard let tx = selectedTransaction else { return "No transaction selected." }

        let category = tx.toCategory?.name ?? "None"
        let date = tx.date ?? Date()
        let amount = String(format: "%.2f", tx.amount)
        let type = tx.type ?? "-"
        let note = tx.note ?? "-"

        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        return """
        Category: \(category)
        Date: \(formatter.string(from: date))
        Amount: \(amount)
        Type: \(type)
        Note: \(note)
        """
    }
}
