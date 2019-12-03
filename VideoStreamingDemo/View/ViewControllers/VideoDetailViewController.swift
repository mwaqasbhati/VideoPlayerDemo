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
    
    // MARK: - Constants

    // MARK: - Instance Variables
    
    let playerView = AVPlayerView()
    var viewModel: VideoViewModel?


    // MARK: - IBOutlets

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var containerPlayer: UIStackView!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    
    // MARK: - View Life Cycle

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
    
    // MARK: - Helper Methods

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
    
    // MARK: - IBActions

    @IBAction func backButtonPressed(_ sender: Any) {
        playerView.queuePlayer.removeAllItems()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - AVPlayerViewDelegate

extension VideoDetailViewController: AVPlayerViewDelegate {
    func avPlayerView(_ playerView: AVPlayerView, resizeAction dimension: AVPlayerView.PLayerDimension) {
        switch dimension {
            case .embed:
                buttonBack.isHidden = false
            case .fullScreen:
                buttonBack.isHidden = true
        }
    }
    func avPlayerView(_ playerView: AVPlayerView, playListItemChanged index: Int) {
        viewModel?.selectedIndex = index
        setupView()
    }
}


