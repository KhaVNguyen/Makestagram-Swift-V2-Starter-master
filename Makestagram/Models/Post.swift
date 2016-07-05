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
import ConvenienceKit
import Foundation

class Post: PFObject, PFSubclassing {
    
    //NSManaged means properties don't need to be initialized and that Parse will handle it
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    var image: Observable<UIImage?> = Observable(nil)
    
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
    var likes: Observable<[PFUser]?> = Observable(nil)
	
	static var imageCache: NSCacheSwift<String, UIImage>!
    
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
			Post.imageCache = NSCacheSwift<String, UIImage>()
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
				if let error = error {
					ErrorHandling.defaultErrorHandler(error)
				}
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            
            } // can pass a closure that is ran once the task is done
        }
        else {
            print("No image given")
        }
    }
    
    func downloadImage() {
		image.value = Post.imageCache[self.imageFile!.name]
        if (image.value == nil) {
            imageFile?.getDataInBackgroundWithBlock {
                (data: NSData?, error: NSError?) -> Void in
				if let error = error {
					ErrorHandling.defaultErrorHandler(error)
				}
                if let data = data {
                    let image = UIImage(data: data, scale: 1.0)
                    self.image.value = image
                }
            }
        }
    }
    
    func fetchLikes() {
        if(likes.value != nil) {
            return
        }
        
        ParseHelper.likesForPost(self) { (likes: [PFObject]?, error: NSError?) -> Void in
			if let error = error {
				ErrorHandling.defaultErrorHandler(error)
			}
            let validLikes = likes?.filter {
                like in like[ParseHelper.ParseLikeFromUser] != nil
            }
            
            // like filterng but instead replacing
            self.likes.value = validLikes?.map { like in
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                return fromUser
            }
        }
    }
    
    func doesUserLikePost(user:PFUser) -> Bool{
        if let likes = likes.value {
            return likes.contains(user)
        }
        else {
            return false
        }
    }
    
    func toggleLikePost(user: PFUser) {
        if doesUserLikePost(user) {
            likes.value = likes.value?.filter { $0 != user }
            ParseHelper.unlikePost(user, post:self)
        }
        else {
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
    
}
