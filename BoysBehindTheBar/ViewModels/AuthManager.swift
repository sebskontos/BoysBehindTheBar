//
//  AuthManager.swift
//  BoysBehindTheBar
//
//  Created by Sebastian Skontos on 9/2/2025.
//

import FirebaseFirestore
import FirebaseAuth

enum UserRole {
    case customer
    case admin
    case unknown
}

class AuthManager: ObservableObject {
    @Published var userID: String?
    @Published var userRole: UserRole = .unknown
    @Published var isLoading = true
    
    private let db = Firestore.firestore()
    
    init() {
        checkAuthStatus()  // Auto-login on app launch
    }

    func checkAuthStatus() {
        if let user = Auth.auth().currentUser {
            userID = user.uid  // ✅ Already authenticated
            fetchUserRole(userID: user.uid)
        } else {
            signInAnonymously()  // ✅ Create an anonymous user
        }
    }

    func signInAnonymously() {
        DispatchQueue.global(qos: .background).async {
            Auth.auth().signInAnonymously { authResult, error in
                if let error = error {
                    print("❌ Authentication failed: \(error.localizedDescription)")
                } else if let user = authResult?.user {
                    self.userID = user.uid
                    self.checkIfUserExistsOrCreate(userID: user.uid)  // ✅ Ensure user has a role
                }
            }
        }
    }
    
    private func checkIfUserExistsOrCreate(userID: String) {
        let userRef = db.collection("users").document(userID)
        
        DispatchQueue.global(qos: .background).async {
            userRef.getDocument { document, error in
                if let document = document, document.exists {
                    self.fetchUserRole(userID: userID)  // ✅ Fetch existing role
                } else {
                    userRef.setData(["userID": userID, "role": "customer"]) { error in
                        if let error = error {
                            print("❌ Error creating user: \(error.localizedDescription)")
                        } else {
                            self.userRole = .customer  // ✅ Default role is "customer"
                        }
                    }
                }
            }
        }
    }
    
    private func fetchUserRole(userID: String) {
        let userRef = db.collection("users").document(userID)

        DispatchQueue.global(qos: .background).async {
            userRef.getDocument { document, error in
                if let error = error {
                    print("❌ Error fetching user role: \(error.localizedDescription)")
                    return
                }
                
                guard let document = document, document.exists else {
                    print("❌ No user role found for user ID: \(userID)")
                    return
                }
                
                if let role = document.get("role") as? String {
                    DispatchQueue.main.async {
                        self.userRole = (role == "admin") ? .admin : .customer
                    }
                    self.isLoading = false
                } else {
                    print("❌ Role field missing in Firestore for user ID: \(userID)")
                }
            }
        }
    }
}
