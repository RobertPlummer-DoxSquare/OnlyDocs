//
//  FollowLikeCell.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 5/7/21.
//

import UIKit
import Firebase

class FollowLikeCell: UITableViewCell {
    
    // MARK: - Properties
     
    var delegate: FollowCellDelegate?
    
     var user: User? {
        
         didSet {
             guard let profileImageUrl = user?.profileImageUrl else { return }
             guard let username = user?.username else { return }
             guard let fullName = user?.fullname else { return }

             profileImageView.loadImage(with: profileImageUrl)

             self.textLabel?.text = username

             self.detailTextLabel?.text = fullName
         }
     }
            
//            user?.checkIfUserIsFollowed(completion: { (followed) in
//
//                if followed {
//
//                    self.followButton.configure(didFollow: true)
//
////                                        self.followButton.setTileColor(.black, for: .normal)
////                                        self.followButton.layer.borderWidth = 0.5
////                                        self.followButton.layer.borderColor = UIColor.lightGray.cgColor
////                                        self.followButton.layer.borderColor = .white
//                } else {
//
//                    self.followButton.configure(didFollow: true)
////                                        self.followButton.setTitle("Follow", for: .normal)
////                                        self.followButton.setTitleColor(.black, for: .normal)
////                                        self.followButton.setTitleColor(.black, for: .normal) = 0
////                                        self.followButton.layer.borderColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
//         }
//     })
//    }
//}
    
        let profileImageView: CustomImageView = {
            let iv = CustomImageView()
            iv.contentMode = .scaleAspectFill
            iv.clipsToBounds = true
            iv.backgroundColor = .lightGray
            return iv
        }()
    
//        lazy var followButton: UIButton = {
//            let button = UIButton(type: .system)
//            button.setTitle("Loading", for: .normal)
//            button.setTitleColor(.white, for: .normal)
//            button.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
//            button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
//            return button
//        }()
    
//    @objc func handleFollowTapped() {
////        print("handleFollowTapped")
//        delegate?.handleFollowTapped(for: self)
//    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    
      addSubview(profileImageView)
      profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
      profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
      profileImageView.layer.cornerRadius = 48 / 2
        
//      addSubview(followButton)
//      followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
//      followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//      followButton.layer.cornerRadius = 3
        
        
        textLabel?.text = "Username"
        
        detailTextLabel?.text = "Full name"
        
        self.selectionStyle = .none
        
    }
    
    override func layoutSubviews() {
            super.layoutSubviews()
    
            textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
            textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
    
            detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y, width: self.frame.width - 108, height: detailTextLabel!.frame.height)
            detailTextLabel?.textColor = .lightGray
            detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
 
        }
    
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }
        
        

