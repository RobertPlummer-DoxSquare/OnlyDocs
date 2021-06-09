//
//  NotificationsVC.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 4/17/21.
//

import UIKit
import Firebase


private let reuseIdentifier = "NotificationCell"


class NotificationsVC: UITableViewController, NotificationCellDelegate {
    

    var timer: Timer?
    var notifications = [Notification]()
    var refresher = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorColor = .clear
        
        navigationItem.title = "Notifications"
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        fetchNotifications()
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notifications.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        
        cell.notification = notifications[indexPath.row]
        
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.currentUser = notification.user
        navigationController?.pushViewController(userProfileVC, animated: true)
        print("User that sent notification is \(notification.user.username)")
    }
    
    
    func handleFollowTapped(for cell: NotificationCell) {
        
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            
            // handle unfollow user
            user.unfollow()
            cell.followButton.configure(didFollow: false)

            
        } else {
            
            // handle unfollow user
            user.follow()
            cell.followButton.configure(didFollow: true)
            
        }
    }
    
    func handlePostTapped(for cell: NotificationCell) {
        guard let post = cell.notification?.post else { return }
        
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        feedVC.viewSinglePost = true
        
        feedVC.post = post
        
        navigationController?.pushViewController(feedVC, animated: true)
        
    }
    
    func handleReloadTable() {
        self.timer?.invalidate()
       
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleSortNotifications), userInfo: nil , repeats: false)
    }
    
    @objc func handleSortNotifications() {
        
        self.notifications.sort {(notification1, notification2) -> Bool in
            return notification1.creationDate > notification2.creationDate
        
        }
        self.tableView.reloadData()
    }
    
    func fetchNotifications() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        NOTIFICATIONS_REF.child(currentUid).observe(.childAdded) { (snapshot) in
        
            let notificationId = snapshot.key
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            Database.fetchUser(with: uid, completion:{ (user) in
                
                if let postId = dictionary["postId"] as? String {
                    
                    Database.fetchPost(with: postId, completion: { (post) in
                    
                        let notification = Notification(user: user, post: post, dictionary: dictionary)
                        self.notifications.append(notification)
                        self.handleReloadTable()
                    })
                    
                } else {
                    let notification = Notification(user: user, dictionary: dictionary)
                    self.notifications.append(notification)
                    self.tableView.reloadData()
                    self.handleReloadTable()
                }
            })
            NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").setValue(1)
        
         }
      }


}
