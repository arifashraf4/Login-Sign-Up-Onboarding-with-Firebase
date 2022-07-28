//
//  RegistrationController.swift
//  Onboarding Tutorial
//
//  Created by arifashraf on 12/05/22.
//

import UIKit
import Firebase

class RegistrationController: UIViewController {

    // MARK: - Properties
    
    private var viewModel = RegistrationViewModel()
    weak var delegate: AuthenticationDelegate?
    
    private let iconImage = UIImageView(image: #imageLiteral(resourceName: "firebase-logo"))
    
    private let emailTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Email")
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let fullnameTextField = CustomTextField(placeholder: "Fullname")
    
    private lazy var signUpButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.title = "Sign Up"
        return button
    }()
    
    private lazy var alreadyHaveAnAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let atts: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(white: 1,
                                                                             alpha: 0.87),
                                                   .font: UIFont.systemFont(ofSize: 16)]
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ",
                                                        attributes: atts)
        
        let boldAtts:[NSAttributedString.Key: Any] = [.foregroundColor: UIColor(white: 1,
                                                                                alpha: 0.87),
                                                      .font: UIFont.boldSystemFont(ofSize: 16)]
        attributedTitle.append(NSAttributedString(string: "Log In",
                                                  attributes: boldAtts))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(showLoginController), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureNotificationObserver()
    }
    
    // MARK: - Selectors
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        
        Service.registerUserWithFirebase(withEmail: email, password: password, fullname: fullname) { error, ref in
            if let error = error {
                print("Error Signing Up \(error.localizedDescription)")
                return
            }
            
            self.delegate?.authenticationComplete()
        }
    }
    
    @objc func showLoginController() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textDidChange(_ sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        } else if sender == passwordTextField {
            viewModel.password = sender.text
        } else {
            viewModel.fullname = sender.text
        }

        updateForm()
    }
    
    // MARK: - Helpers
    func configureUI() {
        
        configureGradientBackground()
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 120, width: 120)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField,
                                                   passwordTextField,
                                                   fullnameTextField,
                                                   signUpButton
                                                   ])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: iconImage.bottomAnchor,
                     left: view.leftAnchor, right: view.rightAnchor,
                     paddingTop: 32,
                     paddingLeft: 32,
                     paddingRight: 32)
        
        view.addSubview(alreadyHaveAnAccountButton)
        alreadyHaveAnAccountButton.centerX(inView: view)
        alreadyHaveAnAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    func configureNotificationObserver() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullnameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

}

// MARK: - FormViewModel

extension RegistrationController: FormViewModel {
    func updateForm(){
        signUpButton.isEnabled = viewModel.shouldEnableButton
        signUpButton.backgroundColor = viewModel.buttonBackgroundColor
        signUpButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
    }
}
