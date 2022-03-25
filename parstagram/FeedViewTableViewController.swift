//
//  FeedViewTableViewController.swift
//  parstagram
//
//  Created by pratyush on 3/25/22.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewTableViewController: UITableViewController {
 
    @IBOutlet weak var tablewView: UITableView!
    var posts = [PFObject]()
    let myRefreshContol = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        myRefreshContol.addTarget(self, action: #selector(loadFeed), for: .valueChanged)
        tableView.refreshControl = myRefreshContol
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadFeed()
    }
    
    @objc func loadFeed() {
        let query = PFQuery(className:"Posts")
        query.includeKey("author")
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
        
        cell.userLabel.text = user.username
        cell.captionLabel.text = post["caption"] as? String
        
        let imageFile = post["image"] as! PFFileObject
        let url = URL(string: imageFile.url!)!
        cell.photoView.af.setImage(withURL: url)
        
       return cell
        
    }
    

}
