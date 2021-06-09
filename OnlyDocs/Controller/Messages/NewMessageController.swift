//
//  NewMessageController.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 6/5/21.
//

import Foundation
import Firebase
import UIKit

private let reuseIdentifier = "NewMessageCell"

class NewMessageController: UITableViewController {
    
    
    var users = [User]()
    var messagesController: MessagesController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        tableView.register(NewMessageCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        fetchUsers()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NewMessageCell
        
        cell.user = users[indexPath.row]
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            
            let user = self.users[indexPath.row]
            self.messagesController?.showChatController(forUser: user)
        }
    }
    
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func configureNavigationBar() {
        navigationItem.title = "New Message"
    
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
    }
    
    func fetchUsers() {
        USER_REF.observe(.childAdded) { (snapshot) in
            let uid = snapshot.key
            
            if uid != Auth.auth().currentUser?.uid {
                Database.fetchUser(with: uid, completion: { (user) in
                    self.users.append(user)
                    self.tableView.reloadData()
                })
            }
        }
    }
}
