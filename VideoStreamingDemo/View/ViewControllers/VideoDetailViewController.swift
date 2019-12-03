//
//  VideoDetailViewController.swift
//  VideoStreamingDemo
//
//  Created by Muhammad Waqas on 01/12/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import UIKit
import AVKit
import Combine

class VideoDetailViewController: UIViewController {
    
    // MARK: - Constants

    // MARK: - Instance Variables
    
    let playerView = AVPlayerView()
    var viewModel: VideoViewModel?
    var videoDetailViewModel: VideoDetailViewModel?
    var titleCancelable: AnyCancellable?
    var descCancelable: AnyCancellable?


    // MARK: - IBOutlets

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var containerPlayer: UIStackView!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var buttonBack: UIButton!
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        guard let selectedIndex = viewModel?.selectedIndex, let video = viewModel?.videos[selectedIndex], let urlStr = viewModel?.videos[selectedIndex].url, let url = URL(string: urlStr) else { return }
        videoDetailViewModel?.video = video
        setupAVPlayerView(url)
    }
    
    // MARK: - Helper Methods

    func addObservers() {
        titleCancelable = videoDetailViewModel?.onFetchVideo.map({ $0.name }).assign(to: \.text, on: labelTitle)
        descCancelable = videoDetailViewModel?.onFetchVideo.map({ $0.description }).assign(to: \.text, on: labelDescription)
    }
    
    private func setupAVPlayerView(_ url: URL) {
        playerView.delegate = self
        containerPlayer.addSubview(playerView)
        playerView.pinEdges(to: containerPlayer)
        let items = viewModel?.videos.map({ (video) -> PlayerItem in
            return PlayerItem(url: video.url ?? "", thumbnail: video.thumbnail ?? "")
        }) ?? []
        playerView.setPlayList(url, items: items, fullView: self.view)
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
        guard let selectedIndex = viewModel?.selectedIndex, let video = viewModel?.videos[selectedIndex] else { return }
        videoDetailViewModel?.video = video
    }
}


