//
//  Comment.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 6/3/21.
//

import Foundation

class Comment {
    
    var uid: String!
    var commentText: String!
    var creationDate: NSDate!
    var user: User?
    
    init(user: User, dictionary: Dictionary<String, AnyObject>) {
        
        self.user = user
        
        if let uid = dictionary["uid"] as? String {
            self.uid = uid
        }
        
        if let commentText = dictionary["commentText"] as? String {
            self.commentText = commentText
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate) as NSDate
        }
    }
}
