//
//  User.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 4/25/21.
//
import Firebase

class User {

var username: String!
var fullname: String!
var profileImageUrl: String!
var uid: String!
var isFollowed = false
 
    
    init(uid: String, dictionary: Dictionary<String, AnyObject>) {
        
        self.uid = uid
        
        if let username = dictionary["username"] as? String {
            self.username = username
        }
        
        if let fullname = dictionary["fullname"] as? String {
            self.fullname = fullname
        }
        
        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
            self.profileImageUrl = profileImageUrl

    }

       
    }

    

    func follow() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // UPDATE: - get uid like this to work with update
        guard let uid = uid else { return }
        
        // set is followed to true
        self.isFollowed = true
        
        // add followed user to current user-following structure
        USER_FOLLOWING_REF.child(currentUid).updateChildValues([uid: 1])
        
        // add current user to followed user-follower structure
        USER_FOLLOWER_REF.child(self.uid).updateChildValues([currentUid: 1])
        
        // upload follow notification to server
        uploadFollowNotificationToServer()
        
        // add followed users posts to current user-feed
        USER_POSTS_REF.child(self.uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
        }
        
        
    }
    
    func unfollow() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // UPDATE: - get uid like this to work with update
        guard let uid = uid else { return }
        
        self.isFollowed = false

        USER_FOLLOWING_REF.child(currentUid).child(self.uid).removeValue()
        
        USER_FOLLOWER_REF.child(self.uid).child(currentUid).removeValue()
        
        USER_POSTS_REF.child(self.uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).child(postId).removeValue()
        }
    }
    
    func checkIfUserIsFollowed(completion: @escaping(Bool) ->()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_FOLLOWING_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.hasChild(self.uid) {
                self.isFollowed = true
                completion(true)
            } else {
                self.isFollowed = false
                completion(false)
            }
        }
    }
    
    func uploadFollowNotificationToServer() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // notification values
        let values = ["checked": 0,
                      "creationDate": creationDate,
                      "uid": currentUid,
                      "type": FOLLOW_INT_VALUE] as [String : Any]
        
        
        NOTIFICATIONS_REF.child(self.uid).childByAutoId().updateChildValues(values)
    }
}

