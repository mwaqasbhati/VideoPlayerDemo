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
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var containerPlayer: UIStackView!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    
    let playerView = AVPlayerView()
    var viewModel: VideoViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupAVPlayerView()
    }
    private func setupView() {
        if let selectedIndex = viewModel?.selectedIndex, let video = viewModel?.videos[selectedIndex] {
            labelTitle.text = video.name
            labelDescription.text = video.description
        }
    }
    private func setupAVPlayerView() {
        
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
        playerView.queuePlayer.removeAllItems()
        navigationController?.popViewController(animated: true)
    }
}

extension VideoDetailViewController: AVPlayerViewDelegate {
    func playListItemChanged(_ index: Int) {
        viewModel?.selectedIndex = index
        setupView()
    }
    
    func resizeAction(_ dimension: AVPlayerView.PLayerDimension) {
        switch dimension {
            case .embed:
                buttonBack.isHidden = false
            case .fullScreen:
                buttonBack.isHidden = true
        }
    }
}


