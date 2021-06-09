//
//  FollowLikeVC.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 5/4/21.
//

import UIKit
import Firebase

private let reuseIdentifer = "FollowCell"

class FollowLikeVC: UITableViewController, FollowCellDelegate {


    // MARK: - Properties
   
    var followCurrentKey: String?
    var likeCurrentKey: String?
    
    enum ViewingMode: Int {
        
        case Following
        case Followers
        case Likes
        
        init(index: Int) {
            switch index {
            case 0: self = .Following
            case 1: self = .Followers
            case 2: self = .Likes
            default: self = .Following
            }
        }
    }
    var postId: String?
    var viewingMode: ViewingMode!
    var uid: String?
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(FollowLikeCell.self, forCellReuseIdentifier: reuseIdentifer)
        
        if let viewingMode = self.viewingMode {
            switch viewingMode {
            case .Followers: navigationItem.title = "Followers"
            case .Following: navigationItem.title = "Following"
            case .Likes: navigationItem.title = "Likes"
            }
            fetchUsers()
        }

        // clear
        tableView.separatorColor = .clear
//        fetchUsers(by: self.viewingMode)

    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 60

       }

    override func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       if users.count > 3 {
           if indexPath.item == users.count - 1 {
               fetchUsers()
           }
       }
   }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count

        }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! FollowLikeCell

        cell.delegate = self

        cell.user = users[indexPath.row]

        return cell
     }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.currentUser = user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }

    // MARK: - FollowCellDelegate Protocol

    func handleFollowTapped(for cell: FollowLikeCell) {
        print("handleFollowTapped")
    }
    
    

    func getDatabaseReference() -> DatabaseReference? {
        guard let viewingMode = self.viewingMode else { return nil }
        switch viewingMode {
        
        case .Followers: return USER_FOLLOWER_REF
        case .Following: return USER_FOLLOWING_REF
        case .Likes: return POST_LIKES_REF
            
        }
    }
    
    func fetchUser(withUid uid: String) {
        Database.fetchUser(with: uid, completion: { (user) in
            self.users.append(user)
            self.tableView.reloadData()
        })
    }

    func fetchUsers() {
        guard let ref = getDatabaseReference() else { return }
        guard let viewingMode = self.viewingMode else { return }
        
        switch viewingMode {
            
        case .Followers, .Following:
            guard let uid = self.uid else { return }
            
            if followCurrentKey == nil {
                ref.child(uid).queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    allObjects.forEach({ (snapshot) in
                        let followUid = snapshot.key
                        self.fetchUser(withUid: followUid)
                    })
                    self.followCurrentKey = first.key
                })
            } else {
                
                ref.child(uid).queryOrderedByKey().queryEnding(atValue: self.followCurrentKey).queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    allObjects.forEach({ (snapshot) in
                        let followUid = snapshot.key
                        
                        if followUid != self.followCurrentKey {
                            self.fetchUser(withUid: followUid)
                        }
                    })
                    self.followCurrentKey = first.key
                })
            }
            
        case .Likes:
            guard let postId = self.postId else { return }
            
            if likeCurrentKey == nil {
                ref.child(postId).queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    allObjects.forEach({ (snapshot) in
                        let likeUid = snapshot.key
                        self.fetchUser(withUid: likeUid)
                    })
                    self.likeCurrentKey = first.key
                })
                
            } else {
                ref.child(postId).queryOrderedByKey().queryEnding(atValue: self.likeCurrentKey).queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                    guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    allObjects.forEach({ (snapshot) in
                        let likeUid = snapshot.key
                        
                        if likeUid != self.likeCurrentKey {
                            self.fetchUser(withUid: likeUid)
                        }
                    })
                    self.likeCurrentKey = first.key
                })
            }
        }
    }
}
        
        
        
//        guard let currentUid = self.uid else { return }
//        guard let ref = getDatabaseReference() else { return }
////        guard let viewingMode = self.viewingMode else { return }
//
//        ref.child(currentUid).observe(.childAdded) { (snapshot) in
//            print(snapshot)
//
//            let userId = snapshot.key
//
//            USER_REF.child(userId).observeSingleEvent(of: .value) { (snapshot) in
//                guard let dictionary = snapshot.value as? Dictionary < String, AnyObject > else {return}
//
//                let user = User(uid: userId, dictionary: dictionary)
////                print("user id is \(user.username)")
//                self.users.append(user)
//                self.tableView.reloadData()
//            }
//
//        }
//
//    }
//
//
//}

