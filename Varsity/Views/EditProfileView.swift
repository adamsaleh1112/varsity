import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authManager: SimpleAuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var avatarUrl: String = ""
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "17171B").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Picture Section
                        VStack(spacing: 16) {
                            AsyncImage(url: URL(string: avatarUrl.isEmpty ? (authManager.currentUser?.avatarUrl ?? "") : avatarUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                    )
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            
                            Button("Change Photo") {
                                showingImagePicker = true
                            }
                            .foregroundColor(Color(hex: "6e27e8"))
                            .font(.subheadline)
                        }
                        .padding(.top, 20)
                        
                        // Form Fields
                        VStack(spacing: 16) {
                            // Display Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Display Name")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("Enter display name", text: $displayName)
                                    .padding()
                                    .background(Color.clear)
                                    .foregroundColor(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "28282B"), lineWidth: 1)
                                    )
                                    .frame(height: 50)
                            }
                            
                            // Bio Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Bio")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("Tell us about yourself", text: $bio, axis: .vertical)
                                    .lineLimit(3...6)
                                    .padding()
                                    .background(Color.clear)
                                    .foregroundColor(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "28282B"), lineWidth: 1)
                                    )
                            }
                            
                            // Avatar URL Field (for now - can replace with image picker later)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Profile Picture URL")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                TextField("Enter image URL", text: $avatarUrl)
                                    .padding()
                                    .background(Color.clear)
                                    .foregroundColor(.white)
                                    .keyboardType(.URL)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "28282B"), lineWidth: 1)
                                    )
                                    .frame(height: 50)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Save Button
                        Button(action: {
                            Task {
                                await authManager.updateProfile(
                                    displayName: displayName.isEmpty ? nil : displayName,
                                    bio: bio.isEmpty ? nil : bio,
                                    avatarUrl: avatarUrl.isEmpty ? nil : avatarUrl
                                )
                                if authManager.errorMessage == nil {
                                    dismiss()
                                }
                            }
                        }) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text("Save Changes")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "6e27e8"))
                            .cornerRadius(12)
                        }
                        .disabled(authManager.isLoading)
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .onAppear {
                // Pre-populate fields with current user data
                displayName = authManager.currentUser?.displayName ?? ""
                bio = authManager.currentUser?.bio ?? ""
                avatarUrl = authManager.currentUser?.avatarUrl ?? ""
            }
        }
        .alert("Error", isPresented: .constant(authManager.errorMessage != nil)) {
            Button("OK") {
                authManager.errorMessage = nil
            }
        } message: {
            Text(authManager.errorMessage ?? "")
        }
    }
}

#Preview {
    EditProfileView()
}
