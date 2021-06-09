//
//  LoginVC.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 4/9/21.
//

import Foundation
import UIKit
import Firebase

class LoginVC: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Onlydocs"
        label.textColor = .white
        label.font = UIFont(name: "Avenir-Light", size: 40)
        label.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        label.backgroundColor = .none
        return label
    }()
    
 let emailTextField: UITextField = {
        let tf = UITextField()

    tf.borderStyle = .none
        tf.textColor = .white
        tf.background = .none
        tf.alpha = 0.6
        tf.keyboardAppearance = .dark
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        return tf
    }()
    
    let passwordTextField: UITextField = {
           let tf = UITextField()
           tf.borderStyle = .none
           tf.background = .none
           tf.textColor = .white
           tf.alpha = 0.6
           tf.keyboardAppearance = .dark
           tf.font = UIFont.systemFont(ofSize: 16)
           tf.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
           return tf
       }()
  
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()

    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        // hide Nav Bar
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(emailTextField)
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 150, paddingLeft: 35, paddingBottom: 0, paddingRight: -30, width: 0, height: 150)
        view.addSubview(passwordTextField)
        
        configureViewComponents()
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 250, paddingRight: 0, width: 0, height: 50)

    }
    
    @objc func handleShowSignUp() {
         let signUpVC = SignUpVC()
         navigationController?.pushViewController(signUpVC, animated: true)
      
    }
    
    @objc func handleLogin () {
    print(123)
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG: Failed to log user in")
                return
            }
            
            guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else {return}
            mainTabVC.configureViewControllers()
            self.dismiss(animated: true, completion: nil)
        }
    }

    
    func configureViewComponents() {
    
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        
        stackView.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 140)
    }
    
}

