//
//  VideoCollectionViewCell.swift
//  VideoStreamingDemo
//
//  Created by Muhammad Waqas on 02/12/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewThumbnail: UIImageView!

    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor.blue : UIColor.clear
            imageViewThumbnail.alpha = isSelected ? 0.75 : 1.0
        }
    }
    
    func setData(_ video: PlayerItem?) {
        if let image = video?.thumbnail {
            imageViewThumbnail.image = UIImage(named: image)
        }
    }
}
