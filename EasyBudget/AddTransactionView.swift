import SwiftUI
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct AddTransactionView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var amount: String = ""
    @State private var note: String = ""
    @State private var type: String = "Income"
    @State private var date = Date()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Category>

    @State private var selectedCategory: Category? = nil
    @State private var isAddingNewCategory: Bool = true
    @State private var newCategoryName: String = ""

    var body: some View {
        Form {
            Section {
                Picker("Type", selection: $type) {
                    Text("Income").tag("Income")
                    Text("Outcome").tag("Outcome")
                }
                .pickerStyle(.segmented)

                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)

                TextField("Note", text: $note)

                DatePicker("Date", selection: $date, displayedComponents: .date)

                Picker("Category", selection: Binding(
                    get: { selectedCategory },
                    set: {
                        selectedCategory = $0
                        isAddingNewCategory = ($0 == nil)
                    })) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.name ?? "Unnamed").tag(Optional(category))
                        }
                        Text("Add New Category").tag(Optional<Category>(nil))
                }

                if isAddingNewCategory {
                    TextField("New Category Name", text: $newCategoryName)
                }

                Button("Save") {
                    let tx = Transaction(context: viewContext)
                    let normalizedAmount = amount.replacingOccurrences(of: ",", with: ".")
                    tx.amount = Float(normalizedAmount) ?? 0.0
                    tx.date = date
                    tx.note = note
                    tx.type = type

                    if isAddingNewCategory && !newCategoryName.isEmpty {
                        let newCategory = Category(context: viewContext)
                        newCategory.name = newCategoryName
                        tx.toCategory = newCategory
                    } else {
                        tx.toCategory = selectedCategory
                    }

                    try? viewContext.save()
                    amount = ""
                    note = ""
                    type = "Income"
                    date = Date()
                    selectedCategory = nil
                    isAddingNewCategory = false
                    newCategoryName = ""
                }
            }
        }
        .background(Color.clear.onTapGesture {
            UIApplication.shared.endEditing()
        })
        .navigationTitle("Add Transaction")
    }
}
