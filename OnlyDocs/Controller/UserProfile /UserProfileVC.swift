//
//  UserProfileVC.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 4/17/21.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let headerIdentifer = "UserProfileHeader"

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {

    var currentUser: User?
    var posts = [Post]()
    var currentKey: String?
    var postToEdit: Post?
    
//    var userToLoadFromSearchVC: User?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        self.collectionView!.register(UserPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifer )
        self.collectionView?.backgroundColor = .white
        
        // fetch user data
        if self.currentUser == nil {
            
            
        fetchCurrentUserData()
            
        }
        
        fetchPosts()
    }

    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1 
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if posts.count > 9 {
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifer, for: indexPath) as! UserProfileHeader
        
        header.delegate = self
        
        header.currentUser = self.currentUser
        
        navigationItem.title = currentUser?.username
        
//        if let user = self.user {
//            header.currentUser = user
//
//        } else if let user = self.userToLoadFromSearchVC {
//            header.currentUser = userToLoadFromSearchVC
           
//        }
        
            return header
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPostCell
    
        cell.post = posts[indexPath.item]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        feedVC.viewSinglePost = true
        feedVC.userProfileController = self
        
        feedVC.post = posts[indexPath.item]
        
        navigationController?.pushViewController(feedVC, animated: true)
    }
//            let postId = snapshot.key
            
//            Database.fetchPost(with: postId, completion: { (post) in
                               
//            POSTS_REF.child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
                
//                guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
                
//                let post = Post(postId: postId, user: user, dictionary: dictionary)
                
//                self.posts.append(post)
//
//                self.posts.sort(by: { (post1, post2) -> Bool in
//                    return post1.creationDate > post2.creationDate
//
//                })
//
//                self.collectionView?.reloadData()
//            })
//
//        }
//    }
    
    func fetchCurrentUserData() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            self.currentUser = user
            self.navigationItem.title = user.username
            self.collectionView?.reloadData()
    }
}
    
    func handleEditFollowTapped(for header: UserProfileHeader) {
        print("follow tapped")
        guard let user = header.currentUser else { return }

        if header.editProfileFollowButton.titleLabel?.text == "Edit Profile" {

            let editProfileController = EditProfileController()
            editProfileController.user = user
            editProfileController.userProfileController = self
            let navigationController = UINavigationController(rootViewController: editProfileController)
            present(navigationController, animated: true, completion: nil)

        } else {
//            // handles user follow/unfollow
            if header.editProfileFollowButton.titleLabel?.text == "Follow" {
                header.editProfileFollowButton.setTitle("Following", for: .normal)
                user.follow()
            } else {
                header.editProfileFollowButton.setTitle("Follow", for: .normal)
                user.unfollow()
            }
        }
    }
    
    func setUserStats(for header: UserProfileHeader) {
        guard let uid = header.currentUser?.uid else { return }
        
        var numberOfFollwers: Int!
        var numberOfFollowing: Int!
        
        // get number of followers
        USER_FOLLOWER_REF.child(uid).observe(.value) { (snapshot) in
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollwers = snapshot.count
            } else {
                numberOfFollwers = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollwers!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            header.followersLabel.attributedText = attributedText
        }
        
        // get number of following
        USER_FOLLOWING_REF.child(uid).observe(.value) { (snapshot) in
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollowing = snapshot.count
            } else {
                numberOfFollowing = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowing!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            header.followingLabel.attributedText = attributedText
        }
        
        // get number of posts
        USER_POSTS_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            let postCount = snapshot.count
            
            let attributedText = NSMutableAttributedString(string: "\(postCount)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            header.postsLabel.attributedText = attributedText
        }
    }
    
    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchPosts()
        collectionView?.reloadData()
    }
    
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }
    
    func fetchPosts(){
        
        var uid: String!
        
        if let user = self.currentUser {
            uid = user.uid
        } else {
            uid = Auth.auth().currentUser?.uid
        }
        
        if currentKey == nil {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
        
            USER_POSTS_REF.child(uid).queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { (snapshot) in
                
                self.collectionView?.refreshControl?.endRefreshing()
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
                allObjects.forEach({(snapshot) in
                    print(snapshot)
                        
                    let postId = snapshot.key
                    
                    self.fetchPost(withPostId: postId)
                    
                })
                self.currentKey = first.key
            })
        } else {
            USER_POSTS_REF.child(uid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 7).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({(snapshot) in
                    print(snapshot)
                        
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
    
    func handleFollowersTapped(for header: UserProfileHeader) {
        let followVC = FollowLikeVC()
        followVC.viewingMode = FollowLikeVC.ViewingMode(index: 1)
//        followVC.viewFollowers = true
        followVC.uid = currentUser?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleFollowingTapped(for header: UserProfileHeader) {
        let followVC = FollowLikeVC()
        followVC.viewingMode = FollowLikeVC.ViewingMode(index: 0)
//        followVC.viewFollowing = true
        followVC.uid = currentUser?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    }
    
//    func fetchPosts(){
//
//        guard let currentUid = Auth.auth().currentUser?.uid else { return }
//
//        USER_POSTS_REF.child(currentUid).observe(.childAdded) { (snapshot) in
//
//
//            let postId = snapshot.key
//
//            POSTS_REF.child(postId).observeSingleEvent(of: .value, with: { (snapshot) in
//
//                guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
//
//                let post = Post(postId: postId, dictionary: dictionary)
//
//                self.posts.append(post)
//
//                self.posts.sort(by: { (post1, post2) -> Bool in
//                    return post1.creationDate > post2.creationDate
//
//                })
//
//                self.collectionView?.reloadData()
//            })
//
//        }
//    }






