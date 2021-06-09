//
//  CommentCell.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 6/3/21.
//

import UIKit
import ActiveLabel

class CommentCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            guard let user = comment?.user else { return }
            guard let profileimageUrl = user.profileImageUrl else { return }
//            guard let username = user.username else { return }
//            guard let commentText = comment?.commentText else { return }
//            guard let timeStamp = getCommentTimeStamp() else { return }
//            
            profileImageView.loadImage(with: profileimageUrl)
            
//            let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
//            attributedText.append(NSAttributedString(string: " \(commentText)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
//            attributedText.append(NSAttributedString(string: " \(timeStamp)", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
//
//            commentLabel.attributedText = attributedText
            configureCommentLabel()
        }
    }
    
    
    
    let profileImageView: CustomImageView = {
           let iv = CustomImageView()
           iv.contentMode = .scaleAspectFill
           iv.clipsToBounds = true
           iv.backgroundColor = .lightGray
           return iv
}()
    
    let commentLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    func getCommentTimeStamp() -> String? {
        
        guard let comment = self.comment else { return nil }
        
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        dateFormatter.maximumUnitCount = 1
        dateFormatter.unitsStyle = .abbreviated
        let now = Date()
        return dateFormatter.string(from: comment.creationDate as Date, to: now)
        

        print("Date to display is \(dateFormatter)")
    
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
      
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(commentLabel)
        commentLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init(coder:) has not been implemented")
    }
    
    func configureCommentLabel() {
        guard let comment = self.comment else { return }
        guard let user = comment.user else { return }
        guard let username = user.username else { return }
        guard let commentText = comment.commentText else { return }
        
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        
        commentLabel.enabledTypes = [.hashtag, .mention, .url, customType]
        
        commentLabel.configureLinkAttribute = {(type, attributes, isSelected) in
            
            var atts = attributes
            
            switch type {
            case .custom:
                atts[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12)
            default: ()
            }
            return atts
        }
        
        commentLabel.customize { (label) in
            label.text = "\(username) \(commentText)"
            label.customColor[customType] = .black
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .black
            label.numberOfLines = 0
        }
        
    }
    
}
