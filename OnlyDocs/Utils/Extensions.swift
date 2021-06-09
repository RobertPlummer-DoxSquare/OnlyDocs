//
//  Extensions.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 4/9/21.
//

import UIKit
import Firebase


extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}



extension Date {
    
    func timeAgoToDisplay() -> String {
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "SECOND"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "MIN"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "HOUR"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "DAY"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "WEEK"
        } else {
            quotient = secondsAgo / month
            unit = "MONTH"
        }
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "S") AGO"
    }
}
    extension UIView {
    
    func anchor(
        top: NSLayoutYAxisAnchor?,
        left: NSLayoutXAxisAnchor?,
        bottom: NSLayoutYAxisAnchor?,
        right: NSLayoutXAxisAnchor?,
        paddingTop: CGFloat,
        paddingLeft: CGFloat,
        paddingBottom: CGFloat,
        paddingRight: CGFloat,
        width: CGFloat,
        height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        
        }
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        
        }
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
            
        }
        if height != 0 {
           heightAnchor.constraint(equalToConstant: height).isActive = true
}
}
        
        func centerX(inView view: UIView) {
            translatesAutoresizingMaskIntoConstraints = false
            centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
}
    

        func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil,
                     paddingLeft: CGFloat = 0, constant: CGFloat = 0) {
            
            translatesAutoresizingMaskIntoConstraints = false
            centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
            
            }
        }

//var imageCache = [String: UIImage]()
//
//extension UIImageView {
    
//    func loadImage(with urlString: String) {
//
//        // check if image exists in cache
//        if let cachedImage = imageCache[urlString] {
//        self.image = cachedImage
//        return
//        }
//
//        // url for image location
//        guard let url = URL(string: urlString) else { return }
//
//        // fetch contents of URL
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//
//        // handle error
//        if let error = error {
//        print("Failed to load image with error", error.localizedDescription)
//
//        }
//
//        // image data
//        guard let imageData = data else { return }
//
//
//        // create image using image data
//        let photoImage = UIImage(data: imageData)
//
//        // set key and value for image cache
//        imageCache[url.absoluteString] = photoImage
//
//        // set image
//        DispatchQueue.main.async {
//        self.image = photoImage
//        }
//        }.resume()
//
//        }
//

extension Database {
    
    static func fetchUser(with uid: String, completion: @escaping(User) -> ()) {
        
        USER_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
    }
    
    static func fetchPost(with postId: String, completion: @escaping(Post) -> ()) {

        POSTS_REF.child(postId).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let ownerUid = dictionary["ownerUid"] as? String else { return }

            Database.fetchUser(with: ownerUid, completion: { (user) in
                let post = Post(postId: postId, user: user, dictionary: dictionary)
                completion(post)
            })
        }
    }
}
    

extension UIButton {
    
    func configure(didFollow: Bool) {
        
        if didFollow {
            
            // handle follow user
            self.setTitle("Following", for: .normal)
            self.setTitleColor(.black, for: .normal)
            self.layer.borderWidth = 0.5
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.backgroundColor = .white
            
        } else {
            
            // handle unfollow user
            self.setTitle("Follow", for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.layer.borderWidth = 0
            self.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        }
    }
}
extension UIViewController {
    
    
    func getMentionedUser(withUsername username: String) {
        USER_REF.observe(.childAdded) { (snapshot) in
            let uid = snapshot.key
            
            USER_REF.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
                
                if username == dictionary["username"] as? String {
                    Database.fetchUser(with: uid, completion: { (user) in
                        let userProfileController = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
                        userProfileController.currentUser = user
                        self.navigationController?.pushViewController(userProfileController, animated: true)
                        return
                    })
                }
            })
        }
    }

    func uploadMentionNotification(forPostId postId: String, withText text: String, isForComment: Bool) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        
        var mentionIntegerValue: Int!

        if isForComment {
            mentionIntegerValue = COMMMENT_MENTION_INT_VALUE
        } else {
            mentionIntegerValue = POST_MENTION_INT_VALUE
        }
        
        for var word in words {
            if word.hasPrefix("@") {
                word = word.trimmingCharacters(in: .symbols)
                word = word.trimmingCharacters(in: .punctuationCharacters)
                
                USER_REF.observe(.childAdded, with: { (snapshot) in
                    let uid = snapshot.key
                    
                    USER_REF.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
                        
                        if word == dictionary["username"] as? String {
                            let notificationValues = ["postId": postId,
                                                      "uid": currentUid,
                                                      "type": COMMMENT_MENTION_INT_VALUE,
                                                      "creationDate": creationDate] as [String: Any]
                            
                            if currentUid != uid {
                                NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(notificationValues)
                            }
                        }
                    })
                })
            }
        }
    }
}




        
