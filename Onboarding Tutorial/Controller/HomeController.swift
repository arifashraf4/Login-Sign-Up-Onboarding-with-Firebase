//
//  HomeController.swift
//  Onboarding Tutorial
//
//  Created by arifashraf on 13/05/22.
//

import UIKit
import Firebase

class HomeController: UIViewController {
    
    // MARK: - Properties
    
    private var user: User? {
        didSet {
            presentOnboardingIfNecessary()
            showWelcomeLabel()
        }
    }
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 28)
        label.text = "Welcome User"
        label.alpha = 0
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateUser()
        configureUI()
    }
    
    // MARK: - Selectors
    
    @objc func handleLogout() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            self.logout()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - API
    
    func fetchUser() {
        Service.fetchUser { user in
            self.user = user
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            self.presentLoginController()
        } catch {
            print("DEBUG: Error Signing Out")
        }
    }
    
    func authenticateUser(){
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                self.presentLoginController()
            }
        } else {
            fetchUser()
        }
    }
    
    // MARK: - Helpers
    
    func configureUI(){
        configureGradientBackground()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barStyle = .black
        navigationItem.title = "Firebase Login"
        
        let image = UIImage(systemName: "arrow.left")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        view.addSubview(welcomeLabel)
        welcomeLabel.centerX(inView: view)
        welcomeLabel.centerY(inView: view)
    }
    
    fileprivate func showWelcomeLabel() {
        guard let user = user else { return }
        guard user.hasSeenOnboarding else { return }
        
        welcomeLabel.text = "Welcome, \(user.fullname)"
        
        UIView.animate(withDuration: 1) {
            self.welcomeLabel.alpha = 1
        }

    }
    
    fileprivate func presentLoginController() {
        let controller = LoginController()
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    fileprivate func presentOnboardingIfNecessary() {
        guard let user = user else { return }
        guard user.hasSeenOnboarding == false else { return }
        
        let controller = OnboardingController()
        controller.delegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)
    }
    
    
}


// MARK: - OnboardingControllerDelegate

extension HomeController: OnboardingControllerDelegate {
    func controllerWantsToDismiss(_ controller: OnboardingController) {
        controller.dismiss(animated: true, completion: nil)
        
        Service.updateUserHasSeenOnboarding { error, ref in
            self.user?.hasSeenOnboarding = true
            print("DEBUG: Did set has seen onboarding")
        }
    }
}

// MARK: - AuthenticationDelegate

extension HomeController: AuthenticationDelegate {
    func authenticationComplete() {
        dismiss(animated: true, completion: nil)
        fetchUser()
    }
    
    
}
