//
//  Constants.swift
//  Onboarding Tutorial
//
//  Created by arifashraf on 14/07/22.
//

import Foundation
import Firebase

let MSG_METRICS = "Metrics"
let MSG_DASHBOARD = "Dashboard"
let MSG_NOTIFICATIONS = "Get Notified"

let MSG_ONBOARDING_METRICS = "Extract Valuable insights and come up with data driven product initiatives to help grow your business"
let MSG_ONBOARDING_DASHBOARD = "Everything you need all in one place, available through our dashboard feature"
let MSG_ONBOARDING_NOTIFICATIONS = "Get notified when important stuff is happening, so you don't miss out on action"

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
