import UIKit
import Parse
import ConvenienceKit

class TimelineViewController: UIViewController, TimelineComponentTarget {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var photoTakingHelper: PhotoTakingHelper?
	// keeps track of the timelne posts
	var timelineComponent: TimelineComponent<Post, TimelineViewController>!
	
	let defaultRange = 0...4
	let additionalRangeSize = 5
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		timelineComponent = TimelineComponent(target: self)
		
        self.tabBarController?.delegate = self
    }
	
	func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
		ParseHelper.timelineRequestForCurrentUser(range) { (result: [PFObject]?, error: NSError?) -> Void in
			let posts = result as? [Post] ?? []
			completionBlock(posts)
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
            post.image.value = image!
            post.uploadPost()
        }
    }
}

extension TimelineViewController: UITableViewDataSource  {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timelineComponent.content.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
        let post = timelineComponent.content[indexPath.row]
        post.downloadImage()
        post.fetchLikes()
        
        cell.post = post
        return cell
    }
}

extension TimelineViewController: UITableViewDelegate {
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		timelineComponent.targetWillDisplayEntry(indexPath.row)
	}
}