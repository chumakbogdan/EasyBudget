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

    var groupedTransactions: [DateComponents: [Transaction]] {
        Dictionary(grouping: transactions) { tx in
            Calendar.current.dateComponents([.year, .month], from: tx.date ?? Date())
        }
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
                        VStack(alignment: .center) {
                            Text("Income")
                                .multilineTextAlignment(.center)
                            Text("\(totalIncome, specifier: "%.2f")")
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.5))
                        .cornerRadius(10)

                        VStack(alignment: .center) {
                            Text("Expenses")
                                .multilineTextAlignment(.center)
                            Text("\(totalExpenses, specifier: "%.2f")")
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.5))
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)

                // Filter row
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

                if filteredTransactions.isEmpty {
                    VStack {
                        Spacer()
                        Text("History is empty")
                            .foregroundColor(.gray)
                            .font(.title2)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    let filteredGrouped = Dictionary(grouping: filteredTransactions) {
                        Calendar.current.dateComponents([.year, .month], from: $0.date ?? Date())
                    }

                    List {
                        ForEach(filteredGrouped.keys.sorted {
                            guard let d1 = Calendar.current.date(from: $0),
                                  let d2 = Calendar.current.date(from: $1) else { return false }
                            return d1 > d2
                        }, id: \.self) { key in
                            Section(header: Text(monthYearString(from: key))
                                .font(.title3)
                                .fontWeight(.semibold)
                            ) {
                                ForEach(filteredGrouped[key] ?? []) { tx in
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
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color(.systemBackground))
                                    .listRowInsets(EdgeInsets())
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .padding()
            .navigationTitle("Dashboard")
        }
    }
}
