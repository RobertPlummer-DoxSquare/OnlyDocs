//
//  CommentViewController .swift
//  OnlyDocs
//
//  Created by Robert Plummer on 6/3/21.
//

import UIKit
import Firebase


private let reuseIdentifier = "CommentCell"

class CommentVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var comments = [Comment]()
    var post: Post?
    var delegate: CommentInputAccesoryViewDelegate?

    lazy var containerView: CommentInputAccessoryView
     = {
//      containerView.backgroundColor = .red
        let frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        let containerView = CommentInputAccessoryView(frame: frame)
        
//        containerView.addSubview(postButton)
//        postButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 0)
//        postButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        
//        containerView.addSubview(commentTextField)
//        commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: postButton.leftAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
//        
//       let separatorView = UIView()
//        separatorView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
//        containerView.addSubview(separatorView)
//        separatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        containerView.delegate = self
        containerView.backgroundColor = .white
        
            return containerView
    }()
    
//    let commentTextField: UITextField = {
//        let tf = UITextField()
//        tf.placeholder = "  Enter Comment"
//        tf.font = UIFont.systemFont(ofSize: 14)
//        return tf
//    }()
//    
//    let postButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Post", for: .normal)
//        button.setTitleColor(.black, for: .normal)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
//        button.addTarget(self, action: #selector(handleUploadComment), for: .touchUpInside)
//        return button
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        
        navigationItem.title = "Comments"
        
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Handlers
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame:frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width:view.frame.width, height: height)
        
//        return CGSize(width: collectionView.frame.width, height: 60)
        
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        
        handleHashtagTapped(forCell: cell)
        
        handleMentionTapped(forCell: cell)
        
        cell.comment = comments[indexPath.item]
        
        return cell
        
        }
    
//    @objc func handleUploadComment() {
        
//        guard let postId = self.post?.postId else { return }
//        guard let commentText = commentTextField.text else { return }
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        let creationDate = Int(NSDate().timeIntervalSince1970)
//        
//        let values = ["commentText": commentText,
//                      "creationDate": creationDate,
//                      "uid": uid] as [String : Any]
//        
//        COMMENT_REF.child(postId).childByAutoId().updateChildValues(values) {(err, ref) in
//            self.uploadCommentNotificationToServer()
//            
//            if commentText.contains("@") {
//            self.uploadMentionNotification(forPostId: postId, withText: commentText, isForComment: true)
//                
//            }
//            
//            self.commentTextField.text = nil
//            
//        }
            
//    }
    
    func handleHashtagTapped(forCell cell: CommentCell) {
        cell.commentLabel.handleHashtagTap { (hashtag) in
            let hashtagController = HashtagController(collectionViewLayout: UICollectionViewFlowLayout())
            hashtagController.hashtag = hashtag.lowercased()
            self.navigationController?.pushViewController(hashtagController, animated: true)
        }
    }
    
    func handleMentionTapped(forCell cell: CommentCell) {
        cell.commentLabel.handleMentionTap { (username) in
            self.getMentionedUser(withUsername: username)
        }
    }
    
    func fetchComments() {
    
        guard let postId = self.post?.postId else { return }
        
        COMMENT_REF.child(postId).observe(.childAdded) { (snapshot) in
        
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
            guard let uid = dictionary["uid"] as? String else { return }
            
//           let comment = Comment(user: User, dictionary: dictionary)
            
            Database.fetchUser(with: uid, completion: { (user) in
                
                let comment = Comment(user: user, dictionary: dictionary)
               
                self.comments.append(comment)
                
//                print("User that commented is \(comment.user?.username)")
                
                self.collectionView?.reloadData()
            })
            
        }
    }
    
    func uploadCommentNotificationToServer() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let postId = self.post?.postId else { return }
        guard let uid = post?.user?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let values = ["checked": 0,
              "creationDate": creationDate,
              "uid": currentUid,
              "type": COMMENT_INT_VALUE,
              "postId": postId] as [String : Any]
    
        if uid != currentUid {
            NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(values)
            
            
        }
    }
}

extension CommentVC: CommentInputAccesoryViewDelegate {
    
    func didSubmit(forComment comment: String) {
        
        guard let postId = self.post?.postId else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let values = ["commentText": comment,
                      "creationDate": creationDate,
                      "uid": uid] as [String : Any]
        
        COMMENT_REF.child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            self.uploadCommentNotificationToServer()
            
            if comment.contains("@") {
                self.uploadMentionNotification(forPostId: postId, withText: comment, isForComment: true)
            }
            
            self.containerView.clearCommentTextView()
        }
    }
}


