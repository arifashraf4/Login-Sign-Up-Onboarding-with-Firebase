//
//  User.swift
//  Onboarding Tutorial
//
//  Created by arifashraf on 20/07/22.
//

import Foundation

struct User {
    let email: String
    let fullname: String
    var hasSeenOnboarding: Bool
    let uid: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.hasSeenOnboarding = dictionary["hasSeenOnboarding"] as? Bool ?? false
    }
}
