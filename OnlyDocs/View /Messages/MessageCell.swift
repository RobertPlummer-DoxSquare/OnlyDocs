//
//  MessagesCell.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 6/5/21.
//

import UIKit
import Firebase


class MessageCell: UITableViewCell {

    
    var message: Message? {
        
        didSet {
           
            guard let messageText = message?.messageText else { return }
            detailTextLabel?.text = messageText
            
            if let seconds = message?.creationDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            timestampLabel.text = dateFormatter.string(from: seconds)
                
            }
            
            configureUserData()
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "2h"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier reusIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reusIdentifier)
        
        selectionStyle = .none
        
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profileImageView.layer.cornerRadius = 50 / 2
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
       
        addSubview(timestampLabel)
        timestampLabel.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
        
        textLabel?.text = "Joker"
        detailTextLabel?.text = "Some test label to see if this works"
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
      
        textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: (textLabel!.frame.height))
        
        detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y + 2, width: self.frame.width - 108, height: (detailTextLabel?.frame.height)!)
        
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        detailTextLabel?.textColor = .lightGray
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    func configureUserData() {
        
        guard let chatPartnerId = message?.getChatPartnerId() else { return }
        
        Database.fetchUser(with: chatPartnerId) { (user) in
        self.profileImageView.loadImage(with: user.profileImageUrl)
        self.textLabel?.text = user.username
        
        
        }
    }
}
