import SwiftUI

struct FullImageView: View {
    var user: User?
    var onClose: () -> Void

    var body: some View {
        if let data = user?.profilePicture,
           let uiImage = UIImage(data: data) {
            ZStack(alignment: .topTrailing) {
                Color.black.ignoresSafeArea()
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)

                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding()
                        .foregroundColor(.white)
                }
            }
        }
    }
}
