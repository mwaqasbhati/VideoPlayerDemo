//
//  Video.swift
//  VideoStreamingDemo
//
//  Created by Muhammad Waqas on 28/11/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import Foundation

struct ResponseData: Codable {
    var data: [Video]
}

struct Video: Codable {
    let name: String?
    let description: String?
    let url: String?
    let thumbnail: String?
}
