import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(hex: "17171B").ignoresSafeArea()
                
                // Subtle pink/blue gradient at top (matching home screen)
                VStack {
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.blue.opacity(0.2), location: 0.0),
                            .init(color: Color.pink.opacity(0.2), location: 1.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 180)
                    .mask(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black, Color.clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    Spacer()
                }
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Logo
                    Image("VarsityLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .padding(.bottom, 40)
                    
                    // Email/Password Fields
                    VStack(spacing: 16) {
                        // Email Field
                        TextField("", text: $email, prompt: Text("Email").foregroundColor(.gray.opacity(0.6)))
                            .padding()
                            .background(Color.clear)
                            .foregroundColor(.white)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "2b2b28"), lineWidth: 1)
                            )
                            .frame(height: 50)
                        
                        // Password Field
                        SecureField("", text: $password, prompt: Text("Password").foregroundColor(.gray.opacity(0.6)))
                            .padding()
                            .background(Color.clear)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "2b2b28"), lineWidth: 1)
                            )
                            .frame(height: 50)
                        
                        // Sign In Button
                        Button(action: {
                            Task {
                                await authManager.signInWithEmail(email: email, password: password)
                            }
                        }) {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                }
                                Text("Sign In")
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "6e27e8"))
                            .cornerRadius(20)
                        }
                        .disabled(authManager.isLoading)
                    }
                    .padding(.horizontal, 40)
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                        Text("or")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 16)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    .padding(.horizontal, 40)
                    
                    // Sign In Buttons
                    VStack(spacing: 12) {
                        // Sign in with Apple
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                Task {
                                    await authManager.signInWithApple()
                                }
                            }
                        )
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .cornerRadius(20)
                        
                        // Coming Soon: Google Sign In
                        Button(action: {
                            // Google sign in coming soon
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.gray)
                                Text("Google Sign-In Coming Soon")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "28282B"))
                            .cornerRadius(20)
                        }
                        .disabled(true)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // Terms and Privacy
                    VStack(spacing: 8) {
                        Text("By signing in, you agree to our")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 16) {
                            Button("Terms of Service") {
                                // Handle terms
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                            
                            Button("Privacy Policy") {
                                // Handle privacy
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .alert("Authentication Error", isPresented: .constant(authManager.errorMessage != nil)) {
            Button("OK") {
                authManager.errorMessage = nil
            }
        } message: {
            Text(authManager.errorMessage ?? "")
        }
    }
}


#Preview {
    LoginView()
}
