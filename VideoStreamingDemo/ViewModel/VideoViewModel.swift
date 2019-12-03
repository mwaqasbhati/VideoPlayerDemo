//
//  VideoViewModel.swift
//  VideoStreamingDemo
//
//  Created by Muhammad Waqas on 28/11/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import Foundation
import Combine


class VideoViewModel {
    
    var onFetchVideo = PassthroughSubject<[Video], APIError>()
    
    var videos: [Video] = [] {
        didSet {
            onFetchVideo.send(videos)
        }
    }
    var selectedIndex = -1
    
    func fetchVideos() {
        let api = WebAPI.fetchVideos(.local)
        api.service?.getVideos(url: api.path, params: [:], completion: { [weak self] (videos, error) in
            guard let `self` = self else { return }
            if error == nil, let videos = videos {
                self.videos = videos
            }
        })
    }
    
}
