import UIKit
import Parse

class TimelineViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var photoTakingHelper: PhotoTakingHelper?
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
        
        ParseHelper.timelineRequestForCurrentUser { (result: [PFObject]?, error: NSError?) -> Void in
            self.posts = result as? [Post] ?? []
            
            for post in self.posts {
                do {
                    let data = try post.imageFile?.getData()
                    post.image = UIImage(data: data!, scale: 1.0)
                } catch {
                    print("could not get image")
                }
            }
            self.tableView.reloadData()
        }
    }
}

// MARK: Tab Bar Delegate

extension TimelineViewController: UITabBarControllerDelegate {

    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is PhotoViewController) {
            takePhoto()
            return false
        } else {
            return true
        }
    }

    func takePhoto() {
        // instantiate PhotoTakingHelper class and provide callback when a photo is selected
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
            let post = Post()
            post.image = image
            post.uploadPost()
        }
    }
}

extension TimelineViewController: UITableViewDataSource  {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
        cell.postImageView.image = posts[indexPath.row].image
        return cell
    }
}