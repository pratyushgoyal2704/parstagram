//
//  FeedViewTableViewController.swift
//  parstagram
//
//  Created by pratyush on 3/25/22.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewTableViewController: UITableViewController, MessageInputBarDelegate {
 
    
    @IBOutlet weak var tablewView: UITableView!
    let commentBar = MessageInputBar()
    
    var posts = [PFObject]()
    var selectedPost: PFObject!
    
    let myRefreshContol = UIRefreshControl()
    var showsCommentBar = false
    override func viewDidLoad() {
        super.viewDidLoad()
        commentBar.inputTextView.placeholder = "Add a comment.."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tablewView.keyboardDismissMode = .interactive
        myRefreshContol.addTarget(self, action: #selector(loadFeed), for: .valueChanged)
        tableView.refreshControl = myRefreshContol
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadFeed()
    }
    
    @objc func loadFeed() {
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
                self.myRefreshContol.endRefreshing()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }

    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let comment = PFObject(className: "Comments")
        
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!

        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            }
            else {
                print("Error saving comment")
            }
        }
        tablewView.reloadData()
        
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comment = (post["comments"] as? [PFObject]) ?? []
        
        return comment.count + 2
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comment = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            
            let user = post["author"] as! PFUser
            
            cell.userLabel.text = user.username
            cell.captionLabel.text = post["caption"] as? String
            
            let imageFile = post["image"] as! PFFileObject
            let url = URL(string: imageFile.url!)!
            cell.photoView.af.setImage(withURL: url)
            return cell
        }
        else if indexPath.row <= comment.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ComentCell") as! ComentCell
            let comment = comment[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
        
        
        
    }
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let
        delegate = windowScene.delegate as? SceneDelegate else { return }
        delegate.window? .rootViewController = loginViewController
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            selectedPost = post
        }
        
  
        
    }
    

}
