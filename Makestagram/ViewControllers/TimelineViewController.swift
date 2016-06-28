import UIKit
import Parse

class TimelineViewController: UIViewController {
    
    var photoTakingHelper: PhotoTakingHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
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
            if let providedImage = image {
                let photoFile = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(providedImage, 1.0)!)
                let post = PFObject(className: "Post")
                post["imageFile"] = photoFile
                post.saveInBackground()
            }
            else {
                print("No image given")
            }
        }
    }
}