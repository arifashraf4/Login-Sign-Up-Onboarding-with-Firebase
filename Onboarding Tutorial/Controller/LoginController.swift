//
//  LoginViewController.swift
//  Onboarding Tutorial
//
//  Created by arifashraf on 11/05/22.
//

import UIKit
import Firebase
import GoogleSignIn

protocol AuthenticationDelegate: AnyObject {
    func authenticationComplete()
}

class LoginController: UIViewController {
    
    // MARK: - Properties
    
    private var viewModel = LoginViewModel()
    weak var delegate: AuthenticationDelegate?
    
    private let iconImage = UIImageView(image: #imageLiteral(resourceName: "firebase-logo"))
    
    private let emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Email")
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.autocapitalizationType = .none
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private lazy var loginButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.title = "Log In"
        return button
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        
        let atts: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(white: 1,
                                                                             alpha: 0.87),
                                                   .font: UIFont.systemFont(ofSize: 15)]
        let attributedTitle = NSMutableAttributedString(string: "Forgot your password? ",
                                                        attributes: atts)
        
        let boldAtts:[NSAttributedString.Key: Any] = [.foregroundColor: UIColor(white: 1,
                                                                                alpha: 0.87),
                                                      .font: UIFont.boldSystemFont(ofSize: 15)]
        attributedTitle.append(NSAttributedString(string: "Get help signing in.",
                                                  attributes: boldAtts))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(showForgotPassword), for: .touchUpInside)
        
        return button
    }()
    
    private let dividerView = DividerView()
    
    private lazy var googleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "btn_google_light_pressed_ios").withRenderingMode(.alwaysOriginal), for: .normal)
        button.setTitle("  Log in with Google", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let atts: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(white: 1,
                                                                             alpha: 0.87),
                                                   .font: UIFont.systemFont(ofSize: 16)]
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ",
                                                        attributes: atts)
        
        let boldAtts:[NSAttributedString.Key: Any] = [.foregroundColor: UIColor(white: 1,
                                                                                alpha: 0.87),
                                                      .font: UIFont.boldSystemFont(ofSize: 16)]
        attributedTitle.append(NSAttributedString(string: "Sign Up",
                                                  attributes: boldAtts))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(showRegistrationController), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureNotificationObserver()
    }
    
    // MARK: - Selectors
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Service.logUserIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error Signing In \(error.localizedDescription)")
                return
            }
            
            self.delegate?.authenticationComplete()
        }
    }
    
    @objc func showForgotPassword() {
        let controller = ResetPasswordController()
        controller.email = emailTextField.text
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleGoogleLogin() {
        
        GIDSignIn.sharedInstance.signIn(with: AppDelegate().signInConfig, presenting: self) { user, error in
            guard error == nil else { return }
            
            
            // If sign in succeeded, display the app's main content View.
            Service.signInWithGoogle(didSignInFor: user!) { error, ref in
                self.delegate?.authenticationComplete()
            }
            
        }
    }
    
    @objc func showRegistrationController() {
        let controller = RegistrationController()
        controller.delegate = delegate
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func textDidChange(_ sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            viewModel.password = sender.text
        }
        
        updateForm()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        configureGradientBackground()
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 120, width: 120)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField,
                                                   passwordTextField,
                                                   loginButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: iconImage.bottomAnchor,
                     left: view.leftAnchor, right: view.rightAnchor,
                     paddingTop: 32,
                     paddingLeft: 32,
                     paddingRight: 32)
        
        
        let secondStack = UIStackView(arrangedSubviews: [forgotPasswordButton,
                                                         dividerView,
                                                         googleLoginButton])
        secondStack.axis = .vertical
        secondStack.spacing = 28
        
        view.addSubview(secondStack)
        secondStack.anchor(top: stack.bottomAnchor,
                           left: view.leftAnchor, right: view.rightAnchor,
                           paddingTop: 24,
                           paddingLeft: 32,
                           paddingRight: 32)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    func configureNotificationObserver() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
}

// MARK: - FormViewModel

extension LoginController: FormViewModel {
    func updateForm(){
        loginButton.isEnabled = viewModel.shouldEnableButton
        loginButton.backgroundColor = viewModel.buttonBackgroundColor
        loginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
    }
}

//MARK: - ResetPasswordControllerDelegate
extension LoginController: ResetPasswordControllerDelegate {
    func didSendResetPasswordLink() {
        navigationController?.popViewController(animated: true)
        print("DEBUG: Show success message here")
    }
}
