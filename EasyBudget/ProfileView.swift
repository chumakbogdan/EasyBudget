import SwiftUI
import CoreData
import PhotosUI

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil
    @State private var isEditingProfile = false
    @State private var tempUserName: String = ""
    @State private var tempProfilePicture: Data? = nil
    @State private var selectedTransaction: Transaction? = nil
    @State private var isShowingTransactionDetail = false
    @State private var pressedTransactionId: UUID? = nil

    @FetchRequest(sortDescriptors: [], animation: .default)
    private var users: FetchedResults<User>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default
    )
    private var transactions: FetchedResults<Transaction>

    var body: some View {
        ZStack {
            VStack {
                ProfileSection(
                    users: users,
                    isEditingProfile: $isEditingProfile,
                    tempUserName: $tempUserName,
                    tempProfilePicture: $tempProfilePicture,
                    selectedImage: $selectedImage,
                    viewContext: viewContext
                )

                TransactionListView(
                    transactions: transactions,
                    onLongPress: { tx in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTransaction = tx
                            pressedTransactionId = tx.id
                            isShowingTransactionDetail = true
                        }
                    },
                    pressedTransactionId: pressedTransactionId,
                    onDelete: deleteTransaction
                )
            }

            if isShowingTransactionDetail, let tx = selectedTransaction {
                TransactionDetailOverlay(
                    transaction: tx,
                    onClose: {
                        withAnimation {
                            isShowingTransactionDetail = false
                            pressedTransactionId = nil
                        }
                    }
                )
            }
        }
        .navigationTitle("Profile")
        .onAppear(perform: ensureDefaultUser)
        .overlay(
            HStack {
                Spacer()
                if !isEditingProfile {
                    Button("Edit") {
                        if let user = users.first {
                            tempUserName = user.name ?? ""
                            tempProfilePicture = user.profilePicture
                            isEditingProfile = true
                        }
                    }
                    .padding()
                }
            },
            alignment: .topTrailing
        )
    }

    private func ensureDefaultUser() {
        guard users.isEmpty else { return }
        let newUser = User(context: viewContext)
        newUser.name = "Jan Kowalski"
        if let defaultImage = UIImage(systemName: "person.circle"),
           let imageData = defaultImage.pngData() {
            newUser.profilePicture = imageData
        }
        try? viewContext.save()
    }

    private func deleteTransaction(at offsets: IndexSet) {
        for index in offsets {
            let tx = transactions[index]
            viewContext.delete(tx)
        }
        try? viewContext.save()
    }
}
