//
//  VideoDetailViewController.swift
//  VideoStreamingDemo
//
//  Created by Muhammad Waqas on 01/12/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import UIKit
import AVKit

class VideoDetailViewController: UIViewController {

    var viewModel: VideoViewModel?
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var containerPlayer: UIStackView!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
               
      //  self.videoURL = URL(string: viewModel?.videos[viewModel?.selectedIndex ?? 0].url ?? "")
        
        let playerView = AVPlayerView()
        playerView.delegate = self
        containerPlayer.addSubview(playerView)
        playerView.pinEdges(to: containerPlayer)
        let items = viewModel?.videos.map({ (video) -> PlayerItem in
            return PlayerItem(url: video.url ?? "", thumbnail: video.thumbnail ?? "")
        }) ?? []
        if let selectedIndex = viewModel?.selectedIndex, let urlStr = viewModel?.videos[selectedIndex].url, let url = URL(string: urlStr) {
            playerView.setPlayList(url, items: items, fullView: self.view)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension VideoDetailViewController: AVPlayerViewDelegate {
    func resizeAction(_ dimension: AVPlayerView.PLayerDimension) {
        switch dimension {
            case .embed:
                buttonBack.isHidden = false
            case .fullScreen:
                buttonBack.isHidden = true
        }
    }
}


