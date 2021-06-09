//
//  SearchVC.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 4/17/21.
//

import UIKit
import Firebase


private let reuseIdentifier = "SearchUserCell"


class SearchVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    

    var users = [User]()
    var filteredUsers = [User]()
    var searchBar = UISearchBar()
    var inSearchMode = false
    var collectionView: UICollectionView!
    var userCurrentKey: String?
    var currentKey: String?
    var posts = [Post]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cell classes
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        tableView.separatorStyle = .none
        
        configureSearchBar()
        
        configureRefreshControl()
        
        fetchUsers()
        
    }

    // MARK: - Table view data source
    
    

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 60
     }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if inSearchMode {
            return filteredUsers.count
        } else {
            
           return users.count
            
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       if users.count > 3 {
           if indexPath.item == users.count - 1 {
               fetchUsers()
           }
       }
   }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var user: User!
        
        if inSearchMode {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        // create instance of user profile vc
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        // passes user from searchVC to userProfileVC
        userProfileVC.currentUser = user
        
        // push view controller
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
        
        var user: User!
        
        if inSearchMode {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        cell.user = user
        
        return cell
    }
    
    func configureConfigureCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let frame = CGRect(x:0, y: 0, width: view.frame.width, height: view.frame.height - (tabBarController?.tabBar.frame.height)! - (navigationController?.navigationBar.frame.height)! - 45)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        
        tableView.separatorColor = .clear
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchPostCell", for: indexPath) as! SearchPostCell
        
        return cell
    }
    
    func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        searchBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        searchBar.tintColor = .black
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        
        fetchUsers()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let searchText = searchText.lowercased()
        
        if searchText.isEmpty || searchText == " " {
            inSearchMode = false
            tableView.reloadData()
        } else {
            inSearchMode = true
            filteredUsers = users.filter({ (user) -> Bool in
                return user.username.contains(searchText)
            })
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
        
        searchBar.showsCancelButton = false
        
        inSearchMode = false
        
        searchBar.text = nil
        
        tableView.separatorColor = .clear
    }
    
    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        self.currentKey = nil
        fetchUsers()
        collectionView?.reloadData()
    }
    
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.tableView?.refreshControl = refreshControl
    }
    
    func fetchUsers() {
        
        if userCurrentKey == nil {
            USER_REF.queryLimited(toLast: 10).observeSingleEvent(of: .value) { (snapshot) in
                
//                self.tableView.refreshControl?.endRefreshing()
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
//                self.tableView.refreshControl?.endRefreshing()
                
                allObjects.forEach({ (snapshot) in
                    let uid = snapshot.key
                    
                    Database.fetchUser(with: uid, completion: { (user) in
                        self.users.append(user)
                        self.tableView.reloadData()
                    })
                })
                self.userCurrentKey = first.key
            }
        } else {
            USER_REF.queryOrderedByKey().queryEnding(atValue: userCurrentKey).queryLimited(toLast: 5).observeSingleEvent(of: .value, with: { (snapshot) in
                
                self.tableView.refreshControl?.endRefreshing()
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                allObjects.removeAll(where: { $0.key == self.userCurrentKey })
                
                allObjects.forEach({ (snapshot) in
                    let uid = snapshot.key

                    if uid != self.userCurrentKey {
                        Database.fetchUser(with: uid, completion: { (user) in
                            self.users.append(user)
                            if self.users.count == allObjects.count  {
                                self.tableView.reloadData()
                            }
                        })
                    }
                })
                self.userCurrentKey = first.key
            })
        }
    }
}
   
