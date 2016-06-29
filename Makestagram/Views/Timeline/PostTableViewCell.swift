//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Kha Nguyen on 6/28/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Bond

class PostTableViewCell: UITableViewCell {
    
    var post: Post? {
        didSet {
            if let post =  post {
                post.image.bindTo(postImageView.bnd_image) // post image needs to be an observable in order to use bindings 
            }
        }
        
    }

    @IBOutlet weak var postImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
