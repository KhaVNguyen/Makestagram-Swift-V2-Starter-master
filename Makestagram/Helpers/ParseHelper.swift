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
    
    static func timelineRequestForCurrentUser(completionBlock: PFQueryArrayResultBlock) {
        
        let followingQuery = PFQuery(className: "Follow")
        followingQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
        
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey("user", equalTo: PFUser.currentUser()!)
        
        // combines the above queries, posts included if either requirements are met
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        query.includeKey("user")
        query.orderByDescending("createdAt")
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    
    
    
}

