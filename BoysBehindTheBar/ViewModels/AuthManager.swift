import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var userID: String?

    init() {
        checkAuthStatus()  // Auto-login on app launch
    }

    func checkAuthStatus() {
        if let user = Auth.auth().currentUser {
            userID = user.uid  // ✅ Already authenticated
        } else {
            signInAnonymously()  // ✅ Create an anonymous user
        }
    }

    func signInAnonymously() {
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                print("❌ Authentication failed: \(error.localizedDescription)")
            } else if let user = authResult?.user {
                self.userID = user.uid
                print("✅ Signed in as anonymous user: \(user.uid)")
            }
        }
    }
}
