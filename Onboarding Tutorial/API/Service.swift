//
//  Service.swift
//  Onboarding Tutorial
//
//  Created by arifashraf on 16/05/22.
//

import Firebase
import GoogleSignIn

typealias DatabaseCompletion = ((Error?, DatabaseReference) -> Void)
typealias AuthDataResultCompletion = ((AuthDataResult?, Error?) -> Void)?
typealias SendPasswordResetCallback = ((Error?) -> Void)

struct Service {
    
    static func logUserIn(withEmail email: String, password: String, completion: AuthDataResultCompletion) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
        
    }
    
    static func registerUserWithFirebase(withEmail email: String,
                                         password: String,
                                         fullname: String,
                                         completion: @escaping(DatabaseCompletion)) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Failed to create user with error: \(error.localizedDescription)")
                return
            }
            
            guard let uid = result?.user.uid else { return }
            let values = ["email": email,
                          "fullname": fullname,
                          "hasSeenOnboarding": false] as [String : Any]
            
            REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
        }

    }
    
    static func signInWithGoogle(didSignInFor user: GIDGoogleUser, completion: @escaping (DatabaseCompletion)) {
        
        let authentication = user.authentication
        guard let idToken = authentication.idToken else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                print("DEBUG: Failed to sign in with google: \(error.localizedDescription)")
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
                if !snapshot.exists() {
                    print("DEBUG: User does not exist, create user")
                    guard let email = result?.user.email else { return }
                    guard let fullname = result?.user.displayName else { return }
                    
                    let values = ["email": email,
                                  "fullname": fullname,
                                  "hasSeenOnboarding": false] as [String : Any]
                    
                    REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
                } else {
                    print("DEBUG: User already exists")
                    completion(error, REF_USERS.child(uid))
                }
            }
            
            
        }
        
    }
 
    static func fetchUser(completion: @escaping(User) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            let uid = snapshot.key
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
    }
    
    static func updateUserHasSeenOnboarding(completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_USERS.child(uid).child("hasSeenOnboarding").setValue(true, withCompletionBlock: completion)
    }
    
    static func resetPassword(forEmail email: String, completion: SendPasswordResetCallback?) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
}
