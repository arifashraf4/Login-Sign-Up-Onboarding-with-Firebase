//
//  AuthButton.swift
//  Onboarding Tutorial
//
//  Created by arifashraf on 11/05/22.
//

import UIKit

class AuthButton: UIButton {
    
    var title: String? {
        didSet {
            setTitle(title, for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 5
        setTitle(title, for: .normal)
        backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).withAlphaComponent(0.5)
        setTitleColor(UIColor(white: 1, alpha: 0.67), for: .normal)
        setHeight(height: 50)
        isEnabled = false
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
