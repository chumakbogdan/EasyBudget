import SwiftUI
import CoreData
import PhotosUI

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil
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
                PhotosPicker(
                    selection: $selectedImage,
                    matching: .images,
                    photoLibrary: .shared()) {
                        if let data = user.profilePicture, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        }
                }
                .onChange(of: selectedImage) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            user.profilePicture = data
                            try? viewContext.save()
                        }
                    }
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
        .onAppear {
            ensureDefaultUser()
        }
    }
    
    private func ensureDefaultUser() {
        if users.isEmpty {
            let newUser = User(context: viewContext)
            newUser.name = "Jan Kowalski"
            
            // Ustaw domyślne zdjęcie jako dane binarne (np. z SF Symbols)
            if let defaultImage = UIImage(systemName: "person.circle"),
               let imageData = defaultImage.pngData() {
                newUser.profilePicture = imageData
            }

            try? viewContext.save()
        }
    }

    func deleteTransaction(at offsets: IndexSet) {
        for index in offsets {
            let tx = transactions[index]
            PersistenceController.shared.container.viewContext.delete(tx)
        }
        try? PersistenceController.shared.container.viewContext.save()
    }
}
