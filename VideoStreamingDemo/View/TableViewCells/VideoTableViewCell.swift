//
//  VideoTableViewCell.swift
//  VideoStreamingDemo
//
//  Created by Muhammad Waqas on 01/12/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    static let cellID = "VideoCell"
    @IBOutlet weak var imageViewThumbnail: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageViewThumbnail.layer.masksToBounds = true
        imageViewThumbnail.layer.cornerRadius = 10.0
        imageViewThumbnail.contentMode = .scaleAspectFill
    }

    func setData(_ video: Video) {
        labelName.text = video.name
        if let image = video.thumbnail {
            imageViewThumbnail.image = UIImage(named: image)
        }
    }

}
