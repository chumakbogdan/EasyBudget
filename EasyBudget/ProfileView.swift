import SwiftUI
import CoreData

struct ProfileView: View {
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var users: FetchedResults<User>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default)
    private var transactions: FetchedResults<Transaction>

    var body: some View {
        VStack(spacing: 16) {
            if let user = users.first {
                Image(systemName: user.profilePicture ?? "person.crop.circle")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .onTapGesture {
                        // Gest: Tap → wybierz zdjęcie
                        print("Change picture")
                    }

                TextField("Name", text: Binding(
                    get: { user.name ?? "" },
                    set: { user.name = $0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            }

            List {
                ForEach(transactions) { tx in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(tx.note ?? "No note")
                            Text(tx.date ?? Date(), style: .date)
                                .font(.caption)
                        }
                        Spacer()
                        Text("\(tx.amount, specifier: "%.2f")")
                            .foregroundColor(tx.type == "Income" ? .green : .red)
                    }
                    .onLongPressGesture {
                        // Gest: długie przytrzymanie → szczegóły
                        print("Show transaction details")
                    }
                }
                .onDelete(perform: deleteTransaction)
            }
        }
        .navigationTitle("Profile")
    }

    func deleteTransaction(at offsets: IndexSet) {
        for index in offsets {
            let tx = transactions[index]
            PersistenceController.shared.container.viewContext.delete(tx)
        }
        try? PersistenceController.shared.container.viewContext.save()
    }
}
