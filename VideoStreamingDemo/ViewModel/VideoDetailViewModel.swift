//
//  VideoDetailViewModel.swift
//  VideoStreamingDemo
//
//  Created by Muhammad Waqas on 03/12/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import Foundation
import Combine

class VideoDetailViewModel {
    
    var onFetchVideo = PassthroughSubject<Video, Never>()

    var video: Video? = nil {
        didSet {
            onFetchVideo.send(video!)
        }
    }
        
}
