import SwiftUI
import PhotosUI
import CoreData

struct ProfileSection: View {
    var users: FetchedResults<User>
    @Binding var isEditingProfile: Bool
    @Binding var tempUserName: String
    @Binding var tempProfilePicture: Data?
    @Binding var selectedImage: PhotosPickerItem?
    @Binding var isShowingFullImage: Bool
    var viewContext: NSManagedObjectContext

    var body: some View {
        VStack {
            if isEditingProfile {
                HStack {
                    Button("Save") {
                        if let user = users.first {
                            user.name = tempUserName
                            user.profilePicture = tempProfilePicture
                            try? viewContext.save()
                            isEditingProfile = false
                        }
                    }
                    Spacer()
                    Button("Cancel") {
                        if let user = users.first {
                            tempUserName = user.name ?? ""
                            tempProfilePicture = user.profilePicture
                            isEditingProfile = false
                            selectedImage = nil
                        }
                    }
                }
                .padding()
            }

            if let user = users.first {
                VStack {
                    if isEditingProfile {
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            ProfileImage(user: user, isEditing: true, imageData: tempProfilePicture)
                        }
                        .onChange(of: selectedImage) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    tempProfilePicture = data
                                    isEditingProfile = true
                                }
                            }
                        }
                    } else {
                        ProfileImage(user: user, isEditing: false, imageData: nil)
                            .onTapGesture { isShowingFullImage = true }
                    }

                    if isEditingProfile {
                        HStack {
                            Spacer()
                            TextField("Name", text: $tempUserName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.title)
                                .fixedSize()
                                .padding(.bottom, 4)
                                
                                
                            Spacer()
                        }
                        .padding(.horizontal)
                    } else {
                        Text(user.name ?? "Jan Kowalski")
                            .font(.title)
                            .padding(.top, 5)
                    }
                }
                .padding(.top, isEditingProfile ? 0 : 60)
            }
        }
    }
}

struct ProfileImage: View {
    let user: User
    let isEditing: Bool
    let imageData: Data?

    var body: some View {
        if let data = isEditing ? imageData : user.profilePicture,
           let uiImage = UIImage(data: data) {
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
}
