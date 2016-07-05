//
//  PostSectionHeaderView.swift
//  Makestagram
//
//  Created by Kha Nguyen on 7/5/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import DateTools

class PostSectionHeaderView: UITableViewCell {
	
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var postTimeLabel: UILabel!
	
	var post: Post? {
		didSet {
			if let post = post {
				usernameLabel.text = post.user?.username
				postTimeLabel.text = post.createdAt?.shortTimeAgoSinceDate(NSDate()) ?? ""
			}
		}
	}
}
