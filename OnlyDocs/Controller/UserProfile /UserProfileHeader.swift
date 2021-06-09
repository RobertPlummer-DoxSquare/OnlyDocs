//
//  UserProfileHeader.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 4/22/21.
//

import UIKit
import Firebase

class UserProfileHeader: UICollectionViewCell {
    
    var delegate: UserProfileHeaderDelegate?
    
    var currentUser: User?
    
    {
        didSet {
            
            configureEditProfileFollowButton()
            
            setUserStats(for: currentUser)
            
            let fullName = currentUser?.fullname
            nameLabel.text = fullName
            
            guard let profileImageUrl = currentUser?.profileImageUrl else { return }
            profileImageView.loadImage(with: profileImageUrl)
        }
    }
    
        let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        
        return iv
    }()

    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .black
        return label
    }()


    let postsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        
        
        return label
    }()
    
    lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        // add gesture recognizer
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        followTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.textColor = .black
        label.addGestureRecognizer(followTap)
        
        return label
    }()
    
    
    lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
    
    
        // add gesture recognizer
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        followTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleEditFollowTapped), for: .touchUpInside)
        return button
    }()
    
    let gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        return button
    }()
    
    let listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    // MARK: - Handlers
    
    @objc func handleFollowersTapped() {
        delegate?.handleFollowersTapped(for: self)
    }
    
    @objc func handleFollowingTapped() {
        delegate?.handleFollowingTapped(for: self)
    }

    @objc func handleEditFollowTapped() {
        delegate?.handleEditFollowTapped(for: self)
    }

    func setUserStats(for user: User?) {
        delegate?.setUserStats(for: self)
    }
    
    
    override init (frame: CGRect) {
        super.init(frame: frame)
    
        addSubview(profileImageView)
        profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
//
//        let stack = UIStackView(arrangedSubviews: [nameLabel])
//        stack.distribution = .fillEqually
//        stack.spacing = 4
//        stack.axis = .vertical
        
//        addSubview(stack)
//        
       
        configureUserStats()
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 10, paddingLeft: 8, paddingBottom: 0, paddingRight: 12, width: 0, height: 30)
    
        configureBottomToolBar()
    }
    
    
    func configureBottomToolBar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = .lightGray
        
        let bottomDividerView = UIView()
        topDividerView.backgroundColor = .lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        bottomDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
    }
    
    func configureUserStats() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    
    func configureEditProfileFollowButton() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let user = self.currentUser else { return }
        
        if currentUid == user.uid {
            
            // configure button as edit profile
            editProfileFollowButton.setTitle("Edit Profile", for: .normal)
           
        } else {
            
            editProfileFollowButton.setTitleColor(.white, for: .normal)
            editProfileFollowButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            
            user.checkIfUserIsFollowed(completion: {(followed) in
            
            if followed {
            // configure button as follow button
                self.editProfileFollowButton.setTitle("Following", for: .normal)
            
            } else {
                
                self.editProfileFollowButton.setTitle("Follow", for: .normal)
            }
        })
    }
}
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
