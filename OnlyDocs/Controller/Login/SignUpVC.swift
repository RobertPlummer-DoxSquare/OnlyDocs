//
//  SignUpVC.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 4/9/21.
//

import UIKit
import Firebase


class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imageSelected = false
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSelectProfilePhoto), for: .touchUpInside)
        return button
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
           tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
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
           tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        //Possible bug here check back!!
           tf.isSecureTextEntry = true
           return tf
    }()
    
    let fullNameTextField: UITextField = {
           let tf = UITextField()
           tf.borderStyle = .none
           tf.background = .none
           tf.textColor = .white
           tf.alpha = 0.6
           tf.keyboardAppearance = .dark
           tf.font = UIFont.systemFont(ofSize: 16)
           tf.attributedPlaceholder = NSAttributedString(string: "Full Name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
           tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
           return tf
    }()
    
    let usernameTextField: UITextField = {
           let tf = UITextField()
           tf.borderStyle = .none
           tf.background = .none
           tf.textColor = .white
           tf.alpha = 0.6
           tf.keyboardAppearance = .dark
           tf.font = UIFont.systemFont(ofSize: 16)
           tf.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
           tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
           return tf
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "already have account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Log In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // background color
        view.backgroundColor = .black
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
       
        configureViewComponents()
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 270, paddingRight: 0, width: 0, height: 50)
        
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
//        var imageSelectedFromPicker = UIImage?.self
        
        
        // selected image
        guard let profileImage = info[.editedImage] as? UIImage else {
            imageSelected = false
            return
        }
        
        // set imageSelected to true
        imageSelected = true
        
        // configure plusPhotoBtn with selected image
                plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
                plusPhotoButton.layer.masksToBounds = true
                plusPhotoButton.layer.borderColor = UIColor.black.cgColor
                plusPhotoButton.layer.borderWidth = 2
                plusPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        self.dismiss(animated: true, completion: nil)
    }
    
  
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//
//        guard let profileImage = info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage else {
////            imageSelected = false
//            return
//
//        }
//
//        imageSelected = true
//
//        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
//        plusPhotoButton.layer.masksToBounds = true
//        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
//        plusPhotoButton.layer.borderWidth = 2
//        plusPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
//        self.dismiss(animated: true, completion: nil)
//    }
    
    @objc func handleSelectProfilePhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    @objc func handleShowLogin() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let fullname = fullNameTextField.text else {return}
        guard let username = usernameTextField.text?.lowercased() else {return}
        
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("DEBUG: Failed to register user with error \(error.localizedDescription)")
                return
            }
            guard let profileImg = self.plusPhotoButton.imageView?.image else { return }
            guard let uploadData = profileImg.jpegData(compressionQuality: 0.3) else { return }
            
            let filename = NSUUID().uuidString
            
            
            // UPDATE: - In order to get download URL must add filename to storage ref like this
            let storageRef = Storage.storage().reference().child("profile_images").child(filename)
            
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
               
                // handle error
                if let error = error {
                    print("Failed to upload image to Firebase Storage with error", error.localizedDescription)
                    return
                }
                
                // UPDATE: - Firebase 5 must now retrieve download url
                storageRef.downloadURL(completion: { (downloadURL, error) in
                    guard let profileImageUrl = downloadURL?.absoluteString else {
                        print("DEBUG: Profile image url is nil")
                        return
                    }
            
            guard let uid = result?.user.uid else { return }

            let values = ["fullname": fullname,
                          "email": email,
                          "profileImageUrl": profileImageUrl,
                          "username": username] as [String : Any]
            
                
                    
            Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: {(error, ref) in
                print("successfully registered user")
                
                guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else { return }

                // configure view controllers in maintabvc
                mainTabVC.configureViewControllers()
                mainTabVC.isInitialLoad = true

                // dismiss login controller
                self.dismiss(animated: true, completion: nil)
            })
        })
    })
    }
    }
    @objc func formValidation() {
        guard emailTextField.hasText,
              passwordTextField.hasText,
              fullNameTextField.hasText,
              usernameTextField.hasText
//              imageSelected == true
            else {
              signUpButton.isEnabled = false
              signUpButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
              return
        }
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    
func configureViewComponents() {
    
        let stackView = UIStackView(arrangedSubviews: [emailTextField, fullNameTextField, usernameTextField, passwordTextField, signUpButton])
    
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 240)
    }
}
