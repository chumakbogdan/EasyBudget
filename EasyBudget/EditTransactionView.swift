import SwiftUI
import UIKit

struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var transaction: Transaction

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Category>

    @State private var note: String = ""
    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var type: String = "Income"

    @State private var selectedCategory: Category? = nil
    @State private var isAddingNewCategory: Bool = false
    @State private var newCategoryName: String = ""

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Type", selection: $type) {
                        Text("Income").tag("Income")
                        Text("Expenses").tag("Expenses")
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
                }
                Button("Save") {
                    let normalizedAmount = amount.replacingOccurrences(of: ",", with: ".")
                    guard let floatAmount = Float(normalizedAmount), floatAmount > 0 else {
                        alertMessage = "Please enter a valid amount."
                        showAlert = true
                        return
                    }

                    guard !note.trimmingCharacters(in: .whitespaces).isEmpty else {
                        alertMessage = "Note cannot be empty."
                        showAlert = true
                        return
                    }

                    if isAddingNewCategory {
                        let trimmedName = newCategoryName.trimmingCharacters(in: .whitespaces)
                        guard !trimmedName.isEmpty else {
                            alertMessage = "Category name cannot be empty."
                            showAlert = true
                            return
                        }

                        if categories.contains(where: { $0.name?.lowercased() == trimmedName.lowercased() }) {
                            alertMessage = "This category already exists."
                            showAlert = true
                            return
                        }

                        let newCategory = Category(context: viewContext)
                        newCategory.name = newCategoryName
                        transaction.toCategory = newCategory
                    } else {
                        transaction.toCategory = selectedCategory
                    }

                    transaction.amount = floatAmount
                    transaction.note = note
                    transaction.date = date
                    transaction.type = type

                    try? viewContext.save()
                    dismiss()
                }
            }
            .navigationTitle("Edit Transaction")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                self.note = transaction.note ?? ""
                self.amount = String(format: "%.2f", transaction.amount)
                self.date = transaction.date ?? Date()
                self.type = transaction.type ?? "Income"
                self.selectedCategory = transaction.toCategory
                self.isAddingNewCategory = (transaction.toCategory == nil)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Validation Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
