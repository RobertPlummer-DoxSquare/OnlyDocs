//
//  HomeController.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 4/15/21.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: - Properties
    let dot = UIView()
    var notificationIDs = [String]()
    var isInitialLoad: Bool?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self

        configureViewControllers()
       
        configureNotificationDot()
        
        checkIfUserIsLoggedIn()
        
//        signOut()
    }
    
    
    // MARK: - Handlers
    
    func configureViewControllers() {
        
        // home feed controller
        let feedVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        // search feed controller
        let searchVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: SearchVC())
        
        // select image controller
        let selectImageVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
        
        // notification controller
        let notificationVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"), rootViewController: NotificationsVC())
        
        // profile controller
        let userProfileVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        // view controllers to be added to tab controller
        viewControllers = [feedVC, searchVC, selectImageVC, notificationVC, userProfileVC]
        
        // tab bar tint color
        tabBar.tintColor = .white
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            
        let selectImageVC = SelectImageVC(collectionViewLayout: UICollectionViewFlowLayout())
        let navController = UINavigationController(rootViewController: selectImageVC)
        navController.modalPresentationStyle = .fullScreen
            navController.navigationBar.tintColor = .white
            
        present(navController, animated: true, completion: nil)
            
        return false
            
        } else if index == 3 {
            print("did select notifications controller")
            dot.isHidden = true
            return true
        }
        return true
    }
    
    
    // function tp create view controllers
    
    func constructNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        
        // construct nav controller
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .white
        
        // return nav controller
        return navController
    }
    
    func configureNotificationDot() {
        
        if UIDevice().userInterfaceIdiom == .phone {
            
            let tabBarHeight = tabBar.frame.height
            
            if UIScreen.main.nativeBounds.height == 2436 {
                // configure dot for iphone x
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - tabBarHeight, width: 6, height: 6)
            } else {
                // configure dot for other phone models
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - 16, width: 6, height: 6)
            }
            
            // create dot
            dot.center.x = (view.frame.width / 5 * 3 + (view.frame.width / 5) / 2)
            
            dot.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)
            dot.layer.cornerRadius = dot.frame.width / 2
            self.view.addSubview(dot)
            dot.isHidden = true
            
        }
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
            let loginVC = LoginVC()
            let navController = UINavigationController(rootViewController: loginVC)
            
            // UPDATE: - iOS 13 presentation fix
            navController.modalPresentationStyle = .fullScreen
            
            self.present(navController, animated: true, completion: nil)
            }
            return
        }
    }
    
    func observeNotifications() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        self.notificationIDs.removeAll()
        
        NOTIFICATIONS_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
//            let notificationId = snapshot.key
            
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }

            allObjects.forEach({ (snapshot) in
                let notificationId = snapshot.key
                
                NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let checked = snapshot.value as? Int else { return }
                    
                    if checked == 0 {
                        self.dot.isHidden = false
//                        self.notificationIDs.append(notificationId)
                    } else {
                        self.dot.isHidden = true
                    }
            })
        })
    }
}
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Debug: error signing out")
        }
    }
}

