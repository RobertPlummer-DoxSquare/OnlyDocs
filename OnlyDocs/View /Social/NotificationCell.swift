//
//  NotificationCell.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 6/4/21.
//

import UIKit

class NotificationCell: UITableViewCell {

    var delegate: NotificationCellDelegate?
    
    var notification: Notification? {
        
            didSet {

                guard let user = notification?.user else { return }
                guard let profileImageUrl = user.profileImageUrl else { return }
                
//                guard let notificationMessage = notification?.notificationType.description else { return }
                
//                // configure notification type
                configureNotificationType()
//
//                // configure notification label
                configureNotificationLabel(withCommentText: nil)
                
//                configureNotificationTimeStamp()
                
                profileImageView.loadImage(with: profileImageUrl)
                
//                notificationLabel.text = "\(username)\(notificationMessage)"
                
                if let post = notification?.post {
                    postImageView.loadImage(with: post.imageUrl)
                }
            }
        }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()

    let notificationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
        
    }()
    
    
    lazy var postImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        
        let postTap = UITapGestureRecognizer(target: self, action: #selector(handlePostTapped))
        postTap.numberOfTapsRequired = 1
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(postTap)
        
        return iv
    }()
    
    @objc func handleFollowTapped() {
        delegate?.handleFollowTapped(for: self)
        
    }
    @objc func handlePostTapped() {
        delegate?.handlePostTapped(for: self)
    }
    
    func configureNotificationLabel(withCommentText commentText: String?) {
        guard let notification = self.notification else { return }
        guard let user = notification.user else { return }
        guard let username = user.username else { return }
        let notificationMessage = notification.notificationType.description
        guard let notificationDate = getNotificationTimeStamp() else { return }
        
//        guard let notificationDate = getNotificationTimeStamp() else { return }
        
//        var notificationMessage: String!
//
//        if let commentText = commentText {
//            if notification.notificationType != .CommentMention {
//                notificationMessage = "\(notification.notificationType.description): \(commentText)"
//            }
//        } else {
//            notificationMessage = notification.notificationType.description
//        }
        
        let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: notificationMessage, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.black]))
        
        attributedText.append(NSAttributedString(string: " \(notificationDate)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))

        notificationLabel.attributedText = attributedText
    }
    
    
    func configureNotificationType() {
        
        guard let notification = self.notification else { return }
        guard let user = notification.user else {return}
        
//        var anchor: NSLayoutXAxisAnchor!
        
        if notification.notificationType != .Follow {
            
            addSubview(postImageView)
            postImageView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 40, height: 40)
            postImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            followButton.isHidden = true
            postImageView.isHidden = false
//            anchor = postImageView.leftAnchor
            
        } else {
            
            addSubview(followButton)
            followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
            followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            followButton.layer.cornerRadius = 3
            followButton.isHidden = false
            postImageView.isHidden = true
//            anchor = followButton.leftAnchor
            
            user.checkIfUserIsFollowed(completion: { (followed) in
                
                if followed {
                    
                    self.followButton.setTitle("Following", for: .normal)
                    self.followButton.setTitleColor(.black, for: .normal)
                    self.followButton.layer.borderWidth = 0.5
                    self.followButton.layer.borderColor = UIColor.lightGray.cgColor
                    self.followButton.backgroundColor = .white
                    
                } else {
                    
                    self.followButton.setTitle("Follow", for: .normal)
                    self.followButton.setTitleColor(.black, for: .normal)
                    self.followButton.layer.borderWidth = 0
                    self.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
                    
                }
                
            })
            
            print("notification type is \(notification.notificationType.rawValue)")
        }
        
        addSubview(notificationLabel)
        notificationLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 100, width: 0, height: 0)
        notificationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
    }
    
    func getNotificationTimeStamp() -> String? {
        
        guard let notification = self.notification else { return nil }
        
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        dateFormatter.maximumUnitCount = 1
        dateFormatter.unitsStyle = .abbreviated
        let now = Date()
        return dateFormatter.string(from: notification.creationDate, to: now)
        

        print("Date to display is \(dateFormatter)")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 40 / 2
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
