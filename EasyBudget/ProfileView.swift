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

    @FetchRequest(sortDescriptors: [], animation: .default)
    private var users: FetchedResults<User>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .default
    )
    private var transactions: FetchedResults<Transaction>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default
    )
    private var categories: FetchedResults<Category>

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                ProfileSection(
                    users: users,
                    isEditingProfile: $isEditingProfile,
                    tempUserName: $tempUserName,
                    tempProfilePicture: $tempProfilePicture,
                    selectedImage: $selectedImage,
                    viewContext: viewContext
                )
                if let user = users.first {
                    VStack(spacing: 10) {
                        VStack{
                            HStack {
                                VStack {
                                    Text("\(transactions.count)")
                                        .font(.title)
                                        .bold()
                                    Text("Transactions")
                                        .font(.subheadline)
                                }
                                .frame(maxWidth: .infinity)

                                VStack {
                                    Text("\(categories.count)")
                                        .font(.title)
                                        .bold()
                                    Text("Categories")
                                        .font(.subheadline)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            VStack {
                                if let creationDate = user.dateCreated {
                                    Text(formattedDate(creationDate))
                                        .font(.title3)
                                        .bold()
                                } else {
                                    Text("–")
                                        .font(.title3)
                                        .bold()
                                }
                                Text("Account Created")
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                        }
                        .padding()
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                Spacer()
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
        newUser.dateCreated = Date()
        if let defaultImage = UIImage(systemName: "person.circle"),
           let imageData = defaultImage.pngData() {
            newUser.profilePicture = imageData
        }
        try? viewContext.save()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
