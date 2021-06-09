//
//  MessagesVC.swift
//  OnlyDocs
//
//  Created by Robert Plummer on 6/5/21.
//

import UIKit
import Firebase


private let reuseIdentifier = "MessagesCell"

class MessagesController: UITableViewController {
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        
        tableView.register(MessageCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        fetchMessages()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        
        cell.message = messages[indexPath.row]
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        let chatPartnerId = message.getChatPartnerId()
        Database.fetchUser(with: chatPartnerId) { (user) in
        self.showChatController(forUser: user)
        }
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navigationController = UINavigationController(rootViewController: newMessageController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func showChatController(forUser user: User) {
        let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    func configureNavigationBar() {
        navigationItem.title = "Messages"
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewMessage))
        
        
    }
    
    func fetchMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        self.messages.removeAll()
        self.messagesDictionary.removeAll()
        self.tableView.reloadData()
        
        USER_MESSAGES_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            print(snapshot)
            
            let uid = snapshot.key
//
            USER_MESSAGES_REF.child(currentUid).child(uid).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                self.fetchMessage(withMessageId: messageId)
//            })
            })
        }
    }
    
    func fetchMessage(withMessageId messageId: String) {
        
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
            
            let message = Message(dictionary: dictionary)
            let chatPartnerId = message.getChatPartnerId()
            self.messagesDictionary[chatPartnerId] = message
            self.messages = Array(self.messagesDictionary.values)
            self.tableView?.reloadData()
//            self.messages.sort(by: { (message1, message2) -> Bool in
//                return message1.creationDate > message2.creationDate
//            })
        }
    }
}
