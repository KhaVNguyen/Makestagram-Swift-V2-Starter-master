//
//  Post.swift
//  Makestagram
//
//  Created by Kha Nguyen on 6/28/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse
import Bond

class Post: PFObject, PFSubclassing {
    
    //NSManaged means properties don't need to be initialized and that Parse will handle it
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    var image: Observable<UIImage?> = Observable(nil)
    
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
    static func parseClassName() -> String {
        return "Post"
    }
    
    override init() {
        super.init()
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            // inform parse about this subclass
            self.registerSubclass()
        }
    }
    
    func uploadPost() {
        if let providedImage = image.value {
            guard let photoFile = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(providedImage, 1.0)!) else {return}
            // guard : code between curly braces runs if photoFile is nil
            self.imageFile = photoFile
            
            user = PFUser.currentUser()
            
            photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
        
            saveInBackgroundWithBlock() { (success: Bool, error: NSError?) in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            
            } // can pass a closure that is ran once the task is done
        }
        else {
            print("No image given")
        }
    }
    
    func downloadImage() {
        if (image.value == nil) {
            imageFile?.getDataInBackgroundWithBlock {
                (data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let image = UIImage(data: data!, scale: 1.0)
                    self.image.value = image
                }
            }
        }
    }
}
