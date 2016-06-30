//
//  ParseHelper.swift
//  Makestagram
//
//  Created by Kha Nguyen on 6/29/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse

class ParseHelper {
    
    static let ParseFollowClass = "Follow"
    static let ParseFollowFromUser = "fromUser"
    static let ParseFollowToUser = "toUser"
    
    static let ParseLikeClass = "Like"
    static let ParseLikeToPost = "toPost"
    static let ParseLikeFromUser = "fromUser"
    
    static let ParsePostUser = "user"
    static let ParsePostCreatedAt = "createdAt"
    
    static let ParseFlaggedContentClass = "FlaggedContent"
    static let ParseFlaggedContentFromUser = "fromUser"
    static let ParseFlaggedContentToPost = "toPost"
    
    // User Relation
    static let ParseUserUsername = "username"
    
    
    static func timelineRequestForCurrentUser(completionBlock: PFQueryArrayResultBlock) {
        
        // query of users that the current user has followed
        let followingQuery = PFQuery(className: ParseFollowClass)
        followingQuery.whereKey(ParseFollowFromUser, equalTo: PFUser.currentUser()!)
        
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, inQuery: followingQuery)
        
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
        
        // combines the above queries, posts included if either requirements are met
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        query.includeKey(ParsePostUser)
        query.orderByDescending(ParsePostCreatedAt)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    // MARK: Likes
    
    static func likePost(user: PFUser, post: Post) {
        
        let likeObject = PFObject(className: ParseLikeClass)
        likeObject[ParseLikeFromUser] = user
        likeObject[ParseLikeToPost] = post
        
        likeObject.saveInBackgroundWithBlock(nil)
    }
    
    static func unlikePost(user: PFUser, post: Post) {
        
        // find the post to be unliked in the Like class
        let unlikedPostQuery = PFQuery(className: ParseLikeClass)
        unlikedPostQuery.whereKey(ParseLikeToPost, equalTo: post)
        unlikedPostQuery.whereKey(ParseLikeFromUser, equalTo: user)
        
        // find like rows with the matching parameters provided by the query
        unlikedPostQuery.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if let results = results {
                for like in results {
                    like.deleteInBackgroundWithBlock(nil)
                }
            }
        }
    }
    
    static func likesForPost(post: Post, completionBlock: PFQueryArrayResultBlock) {
        let likesQuery = PFQuery(className: ParseLikeClass)
        likesQuery.whereKey(ParseLikeToPost, equalTo: post) // found all Likes that were given to the given post
        likesQuery.includeKey(ParseLikeFromUser)
        
        likesQuery.findObjectsInBackgroundWithBlock(completionBlock)
    }
}

extension PFObject {
	public override func isEqual(object: AnyObject?) -> Bool {
		if(object as? PFObject)?.objectId == self.objectId {
			return true
		}
		else {
			return super.isEqual(object)
		}
	}
}

