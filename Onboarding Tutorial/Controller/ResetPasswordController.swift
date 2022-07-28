//
//  ResetPasswordController.swift
//  Onboarding Tutorial
//
//  Created by arifashraf on 12/05/22.
//

import UIKit

protocol ResetPasswordControllerDelegate: AnyObject {
    func didSendResetPasswordLink()
}

class ResetPasswordController: UIViewController {

    // MARK: - Properties
    
    private var viewModel = ResetPasswordViewModel()
    weak var delegate: ResetPasswordControllerDelegate?
    var email: String?
    
    private let iconImage = UIImageView(image: #imageLiteral(resourceName: "firebase-logo"))
    private let emailTextField = CustomTextField(placeholder: "Email")
    
    private lazy var resetPasswordButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.addTarget(self, action: #selector(handleResetPassword), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.title = "Send Reset Link"
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureNotificationObserver()
        loadEmail()
    }
    
    // MARK: - Selectors
    
    @objc func handleResetPassword() {
        guard let email = viewModel.email else { return }

        Service.resetPassword(forEmail: email) { error in
            if let error = error {
                print("DEBUG: Failed to reset password \(error.localizedDescription)")
                return
            }
            
            self.delegate?.didSendResetPasswordLink()
        }
    }
    
    @objc func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textDidChange(_ sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
        }

        updateForm()
    }
    
    // MARK: - Helpers
    
    func configureUI(){
        
        configureGradientBackground()
        
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 16)
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 120, width: 120)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField,
                                                   resetPasswordButton
                                                   ])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: iconImage.bottomAnchor,
                     left: view.leftAnchor, right: view.rightAnchor,
                     paddingTop: 32,
                     paddingLeft: 32,
                     paddingRight: 32)
        
    }
    
    func loadEmail() {
        guard let email = email else { return }
        viewModel.email = email
        
        emailTextField.text = email
        
        updateForm()
    }
    
    func configureNotificationObserver() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

}

// MARK: - FormViewModel

extension ResetPasswordController: FormViewModel {
    func updateForm(){
        resetPasswordButton.isEnabled = viewModel.shouldEnableButton
        resetPasswordButton.backgroundColor = viewModel.buttonBackgroundColor
        resetPasswordButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
    }
}
