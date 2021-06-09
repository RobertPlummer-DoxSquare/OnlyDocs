//
//  FeedVC.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 4/18/21.
//

import UIKit
import FirebaseAuth
import Firebase
import ActiveLabel

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, FeedCellDelegate {
    
    var posts = [Post]()
    var viewSinglePost = false
    var post: Post?
    var currentKey: String?
    var userProfileController: UserProfileVC?
    var postToEdit: Post?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = .white
        
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        configureNavigationBar()
        
        if !viewSinglePost {
            fetchPosts()
        }
        
        updateUserFeeds()
    }

    // MARK: UICollectionViewDataSource

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        var height = width + 8 + 40 + 8
        height += 50
        height += 60
        return CGSize(width: width, height: height)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > 4 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if viewSinglePost {
            return 1
        } else {
                return posts.count
            }
        }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        
        cell.delegate = self
        
        if viewSinglePost {
            if let post = self.post {
            cell.post = post
        }
        } else {
                cell.post = posts[indexPath.item]
            }
        
        handleHashTagTapped(forCell: cell)
        // Configure the cell
        
        handleUsernameLabelTapped(forCell: cell)
        
        handleMentionTapped(forCell: cell)
    
        return cell
    }
    
        func handleUsernameTapped(for cell: FeedCell) {
            
            guard let post = cell.post else { return }
            
            let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
            
            userProfileVC.currentUser = post.user
            
            navigationController?.pushViewController(userProfileVC, animated: true)
        }
        
        func handleOptionsTapped(for cell: FeedCell) {
            print("handle options tapped")
            guard let post = cell.post else {return}
            
            if post.ownerUid == Auth.auth().currentUser?.uid {
                let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
                
                alertController.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { (_) in
                    post.deletePost()
                    
                    if !self.viewSinglePost {
//                        self.handleRefresh()
                    } else {
                        if let userProfileController = self.userProfileController {
                            _ = self.navigationController?.popViewController(animated: true)
                          userProfileController.handleRefresh()
                        }
                    }
                }))
                
//                alertController.addAction(UIAlertAction(title: "Edit Post", style: .default, handler: { (_) in
//
//                    let uploadPostController = UploadPostVC()
////                    let navigationController = UINavigationController(rootViewController: uploadPostController)
//                    uploadPostController.postToEdit = post
//                    uploadPostController.uploadAction = UploadPostVC.UploadAction(index: 0)
//                    self.navigationController?.pushViewController(uploadPostController, animated: true)
//                    self.present(navigationController, animated: true, completion: nil)
//                }))
//
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
            }
        }
        

    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool) {
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
            
            if post.didLike {
                
                // handle unlike post
                if !isDoubleTap {
                        post.adjustLikes(addLike: false, completion: {(likes) in
                        cell.likesLabel.text = "\(likes) likes"
                        cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
//                        self.sendLikeNotificationsToServer(post: post, didLike: false)
                        self.updateLikeStructures(with: postId, addLike: false)
                        
                })
            }
//                updateLikeStructures(with: postId, addLike: false)
        } else {
                // handle like post
                post.adjustLikes(addLike: true, completion: {(likes) in
                cell.likesLabel.text = "\(likes) likes"
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
//                self.sendLikeNotificationsToServer(post: post, didLike: true)
                self.updateLikeStructures(with: postId, addLike: true)
                
            })
//                updateLikeStructures(with: postId, addLike: true)
        }
    }
    
    func handleShowLikes(for cell: FeedCell) {
        guard let post = cell.post else {return}
        guard let postId = post.postId else {return}
        
        let followLikeVC = FollowLikeVC()
        followLikeVC.viewingMode = FollowLikeVC.ViewingMode(index: 2)
        followLikeVC.postId = postId
        navigationController?.pushViewController(followLikeVC, animated: true)
    }
    func handleConfigureLikeButton(for cell: FeedCell) {
        guard let post = cell.post else { return }
        guard let postId = post.postId else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        
        USER_LIKES_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.hasChild(postId) {
        
                print("User has liked post")
                post.didLike = true
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
            }
        }
    }
        
    func handleCommentTapped(for cell: FeedCell) {
           guard let post = cell.post else { return }
           let commentVC = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
           commentVC.post
            = post
           navigationController?.pushViewController(commentVC, animated: true)
            
        }
        
    @objc func handleShowMessages(){
        let messagesController = MessagesController()
        navigationController?.pushViewController(messagesController, animated: true)
        
    }
    
    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchPosts()
        collectionView?.reloadData()
    }
    
    func updateLikeStructures(with postId: String, addLike: Bool) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
       
        if addLike {
        // update user-likes structure
        USER_LIKES_REF.child(currentUid).updateChildValues([postId: 1])
        
        // update post-likes structure
        POST_LIKES_REF.child(postId).updateChildValues([currentUid: 1])
            
        } else {
            //remove like from strucutre
            USER_LIKES_REF.child(currentUid).child(postId).removeValue()
            
            POST_LIKES_REF.child(postId).child(currentUid).removeValue()
            
        }
    }
    
    func handleHashTagTapped(forCell cell: FeedCell) {
        cell.captionLabel.handleHashtagTap { (hashtag) in
        let hashtagController = HashtagController(collectionViewLayout: UICollectionViewFlowLayout())
            hashtagController.hashtag = hashtag
            self.navigationController?.pushViewController(hashtagController, animated: true)
            
        }
    }
    
    func handleMentionTapped(forCell cell: FeedCell) {
        cell.captionLabel.handleMentionTap { (username) in
            self.getMentionedUser(withUsername: username)
        }
    }
    
    func handleUsernameLabelTapped(forCell cell: FeedCell) {
        
        guard let user = cell.post?.user else { return }
        guard let username = user.username else { return }
                
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        
        cell.captionLabel.handleCustomTap(for: customType) { (username) in
            print("USERNAME IS \(username)")
            
            let userProfileController = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
            
            userProfileController.currentUser = user
            
            self.navigationController?.pushViewController(userProfileController, animated: true)
                                                                     
        }
    }
    
    func configureNavigationBar() {
        
        if !viewSinglePost {
            
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: .plain, target: self, action: #selector(handleShowMessages))
        
        self.navigationItem.title = "Feed"
        
        }
    
    @objc func handleLogout() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            
        do {
                try Auth.auth().signOut()
                let loginVC = LoginVC()
                let navController = UINavigationController(rootViewController: loginVC)
                
                // UPDATE: - iOS 13 presentation fix
                navController.modalPresentationStyle = .fullScreen
                
                self.present(navController, animated: true, completion: nil)
            } catch {
                print("Failed to sign out")
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        
    }
    
    func updateUserFeeds() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let followingUserId = snapshot.key
            
            USER_POSTS_REF.child(followingUserId).observe(.childAdded, with:  { (snapshot) in
                let postId = snapshot.key
                
                USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
                
            })
        }
        
        USER_POSTS_REF.child(currentUid).observe(.childAdded){ (snapshot) in
            let postId = snapshot.key
        
            USER_FEED_REF.child(currentUid).updateChildValues([postId: 1])
        }
    }
  
    func fetchPosts() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        if currentKey == nil {
            USER_FEED_REF.child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                
                self.collectionView?.refreshControl?.endRefreshing()
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ (snapshot) in
                    let postId = snapshot.key
                    self.fetchPost(withPostId: postId)
                })
                self.currentKey = first.key
            })
        } else {
            USER_FEED_REF.child(currentUid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ (snapshot) in
                    let postId = snapshot.key
                    if postId != self.currentKey {
                        self.fetchPost(withPostId: postId)
                    }
                })
                self.currentKey = first.key
            })
        }
    }

func fetchPost(withPostId postId: String) {
    Database.fetchPost(with: postId) { (post) in
        self.posts.append(post)

        self.posts.sort(by: { (post1, post2) -> Bool in
            return post1.creationDate > post2.creationDate
        })
        self.collectionView?.reloadData()
    }
}
}

//    func fetchPosts() {
//
//        print ("fetch post function called")
//
//        guard let currentUid = Auth.auth().currentUser?.uid else { return }
//
//        if let currentKey == nil {
//
//        USER_FEED_REF.child(currentUid).observe(.childAdded) { (snapshot) in
//
//            let postId = snapshot.key
//
//            Database.fetchPost(with: postId, completion: { (post) in
//
//            self.posts.append(post)
//
//            self.posts.sort(by: { (post1, post2) -> Bool in
//                                return post1.creationDate > post2.creationDate
//            })
//
//            self.collectionView?.refreshControl?.endRefreshing()
//
//            self.collectionView?.reloadData()
//
//                })
//            }
//        }
//    }
//}
//        func sendLikeNotificationsToServer(post: Post, didLike: Bool) {
//
////            guard let currentUid = Auth.auth().currentUser?.uid else { return }
//            guard let postId = post.postId else { return }
////            let creationDate = Int(NSDate().timeIntervalSince1970)
//
//            if didLike {
//                // notification values
//                if currentUid != post.ownerUid {
//
//                let values = ["checked": 0,
//                              "creationDate": creationDate,
//                              "uid": currentUid,
//                              "type": LIKE_INT_VALUE,
//                              "postId": postId] as [String : Any]
//
//                    let notificationRef =  NOTIFICATIONS_REF.child(post.ownerUid).childByAutoId()
//
//                    notificationRef.updateChildValues(values, withCompletionBlock: {      (err, ref) in
//                        USER_LIKES_REF.child(currentUid).child(postId).setValue(notificationRef.key)
//
//                    })
//
//            }
//
//
//        } else {
//
////                USER_LIKES_REF.child(currentUid).child(postId).observeSingleEvent(of: .value, with: {(snapshot) in
//
//                    guard let notificationID = snapshot.value as? String else { return }
//
//                    NOTIFICATIONS_REF.child(post.ownerUid).child(notificationID).removeValue()
//
//                })
//        }
            
//        }
//    }
//}
