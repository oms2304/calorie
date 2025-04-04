import SwiftUI
import FirebaseAuth

class AppState: ObservableObject {
<<<<<<< HEAD
    @Published var isUserLoggedIn: Bool = false

    init() {
        // Listen for authentication state changes
        Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                if let user = user {
                    print("✅ Firebase Auth State Changed: User logged in: \(user.uid)")
                    self.isUserLoggedIn = true
                } else {
                    print("❌ Firebase Auth State Changed: No user logged in")
                    self.isUserLoggedIn = false
                }
            }
        }
    }

    /// Manually set the login state
    func setUserLoggedIn(_ loggedIn: Bool) {
        DispatchQueue.main.async {
            self.isUserLoggedIn = loggedIn
        }
=======
    @Published var isUserLoggedIn: Bool = Auth.auth().currentUser != nil

    func setUserLoggedIn(_ loggedIn: Bool) {
        self.isUserLoggedIn = loggedIn
>>>>>>> d3d7eb3 (Initial commit)
    }
}
