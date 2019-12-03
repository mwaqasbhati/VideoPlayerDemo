//
//  AVPlayerView.swift
//  VideoStreamingDemo
//
//  Created by Muhammad Waqas on 02/12/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import Foundation
import AVKit

struct PlayerItem {
    let url: String
    let thumbnail: String
}

protocol AVPlayerViewDelegate: class {
    func avPlayerView(_ playerView: AVPlayerView, resizeAction dimension: AVPlayerView.PLayerDimension)
    func avPlayerView(_ playerView: AVPlayerView, playListItemChanged index: Int)
}

class AVPlayerView: UIView {
    
    // MARK: - Constants

    // MARK: - Instance Variables

    private var playButton: UIButton!
    private var playerLayer: AVPlayerLayer!
    private var playerTimeLabel: UILabel!
    private var seekSlider: UISlider!
    private var activityView = UIActivityIndicatorView(style: .large)
    private var isActive: Bool = false
    private var isShowOverlay: Bool = true
    private var isFullScreen: Bool = false
    private var dimension: PLayerDimension = .embed
    private var playerItems: [PlayerItem]?
    private var mainContainerView: UIView?
    private var task: DispatchWorkItem? = nil
    private var heightConstraint: NSLayoutConstraint?
    private var topConstraint: NSLayoutConstraint?
    
    let overlayView = UIView()
    let videosStackView = UIStackView()
    var delegate: AVPlayerViewDelegate?
    var queuePlayer: AVQueuePlayer!
    
    lazy var collectionView: UICollectionView =  {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    enum PLayerDimension {
        case embed
        case fullScreen
    }
    
    var duration: CMTime? {
        return self.queuePlayer.currentItem?.asset.duration
    }
    
    // MARK: - View Initializers

    override init(frame: CGRect) {
      super.init(frame: frame)
      setupPlayer()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlayer()
    }
    
    // MARK: - Helper Methods

    func setPlayList(_ initilURL: URL, items: [PlayerItem], fullView: UIView? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = heightAnchor.constraint(equalToConstant: 400.0)
        heightConstraint?.isActive = true
        if let top = fullView?.safeAreaLayoutGuide.topAnchor {
            topConstraint = superview?.topAnchor.constraint(equalTo: top, constant: 55.0)
            topConstraint?.isActive = true
        }
        playerItems = items
        layoutIfNeeded()
        playerLayer.frame = self.bounds
        mainContainerView = fullView
        loadVideo(initilURL)
        collectionView.reloadData()
    }
    private func setupPlayer() {
        
        createPlayerView()
        createOverlayView()

        queuePlayer.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 100),
            queue: DispatchQueue.main,
            using: { [weak self] (cmtime) in
                print(cmtime)
                self?.playerTimeLabel.text = cmtime.description
        })
    }
    private func loadVideo(_ url: URL) {
        queuePlayer.removeAllItems()
        let playerItem = AVPlayerItem.init(url: url)
        queuePlayer.insert(playerItem, after: nil)
        playerTimeLabel.text = CMTime.zero.description
        seekSlider.value = 0.0
    }
    
    private func seekToTime(_ seekTime: CMTime) {
        print(seekTime)
        self.queuePlayer.currentItem?.seek(to: seekTime, completionHandler: nil)
        self.playerTimeLabel.text = seekTime.description
    }
    
    private func createPlayerView() {
        queuePlayer = AVQueuePlayer()
        queuePlayer.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        playerLayer = AVPlayerLayer(player: queuePlayer)
        playerLayer.backgroundColor = UIColor.black.cgColor
        playerLayer.videoGravity = .resizeAspect
        self.layer.addSublayer(playerLayer)
    }
    private func createOverlayView() {
        
        // activity indicator
        activityView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityView)
        activityView.color = .white
        activityView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityView.startAnimating()
        
        // play/pause button
        let playButton = UIButton()
        playButton.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 85).isActive = true
        playButton.setImage(UIImage(named: "play"), for: .normal)
        playButton.addTarget(
            self,
            action: #selector(self.clickPlayButton(_:)),
            for: .touchUpInside)
        self.playButton = playButton
        
        // time label
        
        let label = UILabel()
        label.text = CMTime.zero.description
        label.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(label)
        label.textColor = .blue
        label.textAlignment = .center
        label.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 10).isActive = true
        label.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -10).isActive = true
        label.widthAnchor.constraint(equalToConstant: 60).isActive = true
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
        playerTimeLabel = label
        
        // seek slider
        
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(slider)
        slider.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 5).isActive = true
        slider.centerYAnchor.constraint(equalTo: label.centerYAnchor, constant: 0).isActive = true
      //  slider.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -10).isActive = true
        slider.addTarget(
            self,
            action: #selector(self.changeSeekSlider(_:)),
            for: .valueChanged)
        seekSlider = slider
        
        // resize button
        
        let resizeButton = UIButton()
        resizeButton.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(resizeButton)
        resizeButton.setImage(UIImage(named: "resize"), for: .normal)
        resizeButton.addTarget(self, action: #selector(self.resizeButtonTapped), for: .touchUpInside)
        resizeButton.leadingAnchor.constraint(equalTo: slider.trailingAnchor, constant: 10).isActive = true
        resizeButton.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -10).isActive = true
        resizeButton.centerYAnchor.constraint(equalTo: slider.centerYAnchor, constant: 0).isActive = true
        resizeButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        resizeButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        
        // videos stackview
        videosStackView.isHidden = true
        videosStackView.axis = .horizontal
        videosStackView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(videosStackView)
        videosStackView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 10).isActive = true
        videosStackView.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -10).isActive = true
        videosStackView.bottomAnchor.constraint(equalTo: self.seekSlider.topAnchor, constant: -10.0).isActive = true
        videosStackView.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
        
        // collectionView
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        videosStackView.addSubview(collectionView)
        collectionView.register(UINib(nibName: "VideoCell", bundle: nil), forCellWithReuseIdentifier: "videoCellId")
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.leadingAnchor.constraint(equalTo: videosStackView.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: videosStackView.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: videosStackView.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: videosStackView.bottomAnchor).isActive = true

        overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(overlayView)
        overlayView.backgroundColor = .clear
        overlayView.pinEdges(to: self)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
        
    }
    
    // MARK: - Actions
    
    @objc func changeSeekSlider(_ sender: UISlider) {
        guard let duration = duration else { return }
        let seekTime = CMTime(seconds: Double(sender.value) * duration.asDouble, preferredTimescale: 100)
        self.seekToTime(seekTime)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if isShowOverlay {
            overlayView.isHidden = true
            task?.cancel()
        } else {
            overlayView.isHidden = false
            task = DispatchWorkItem {
               self.overlayView.isHidden = true
               self.isShowOverlay = !self.isShowOverlay
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(10), execute: task!)
        }
        isShowOverlay = !isShowOverlay
    }
    @objc func clickPlayButton(_ sender: UIButton) {
        playButton.setImage(UIImage(named: isActive ? "play" : "pause"), for: .normal)
        isActive ? queuePlayer.pause() : queuePlayer.play()
        self.isActive = !self.isActive
        print("clicked -> \(isActive)")
    }
    @objc func resizeButtonTapped(_ sender:UIButton) {
        switch dimension {
        case .embed:
            dimension = .fullScreen
            if let height = mainContainerView?.frame.size.height, let top = mainContainerView?.safeAreaLayoutGuide.topAnchor, let bottom = mainContainerView?.safeAreaInsets.bottom, let topSafeArea = mainContainerView?.safeAreaInsets.top {
                heightConstraint?.isActive = false
                topConstraint?.isActive = false
                heightConstraint = heightAnchor.constraint(equalToConstant: height - bottom - topSafeArea)
                topConstraint = superview?.topAnchor.constraint(equalTo: top)
                heightConstraint?.isActive = true
                topConstraint?.isActive = true
            }
            delegate?.avPlayerView(self, resizeAction: dimension)
            layoutIfNeeded()
            playerLayer.frame = bounds
            videosStackView.isHidden = false
            bringSubviewToFront(mainContainerView ?? UIView())
        case .fullScreen:
            dimension = .embed
            heightConstraint?.isActive = false
            topConstraint?.isActive = false
            heightConstraint = heightAnchor.constraint(equalToConstant: 400.0)
            if let top = mainContainerView?.safeAreaLayoutGuide.topAnchor {
                topConstraint = superview?.topAnchor.constraint(equalTo: top, constant: 55.0)
                topConstraint?.isActive = true
            }
            heightConstraint?.isActive = true
            delegate?.avPlayerView(self, resizeAction: dimension)
            layoutIfNeeded()
            playerLayer.frame = bounds
            videosStackView.isHidden = true
        }
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async {[weak self] in
                    if newStatus == .playing || newStatus == .paused {
                        self?.activityView.isHidden = true
                    } else {
                        self?.activityView.isHidden = false
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionView Delegate & Datasource

extension AVPlayerView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playerItems?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCellId", for: indexPath) as? VideoCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.setData(playerItems?[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = URL(string: playerItems?[indexPath.row].url ?? "") {
            loadVideo(url)
            delegate?.avPlayerView(self, playListItemChanged: indexPath.row)
        }
    }
}

