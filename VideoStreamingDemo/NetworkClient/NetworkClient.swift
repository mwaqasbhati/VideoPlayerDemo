//
//  NetworkClient.swift
//  VideoStreamingDemo
//
//  Created by Muhammad Waqas on 28/11/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import Foundation
import Combine


enum APIError: LocalizedError {
    case urlNotFound
    case statusCode
    
    var localizedDescription: String {
        switch self {
        case .urlNotFound:
            return "Please provide url."
        case .statusCode:
            return "Response status code is invalid."
        default:
            return "Some unknown error occur, please try again later."
        }
    }
}

protocol APIManagable {
    func buildURLRequest(_ url: String, params: [String: String]) throws -> URLRequest
    func fetch<T: Codable>(_ request: URLRequest, value: T.Type, completion: (_ response: Any?, _ error: APIError?)->())
}

extension APIManagable {
    
    func buildURLRequest(_ url: String, params: [String : String]) throws -> URLRequest {
        guard let url = URL(string: url) else { throw APIError.urlNotFound }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            print("URL :\(url)")
            print("Request :\(params)")
        } catch let error {
            throw error
            print(error.localizedDescription)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    func fetch<T: Codable>(_ request: URLRequest, value: T.Type, completion: (_ response: Any?, _ error: APIError?)->()) {
        var cancellable: AnyCancellable? = nil
        cancellable = URLSession.shared.dataTaskPublisher(for: request)
        .tryMap { output in
            guard let response = output.response as? HTTPURLResponse, response.statusCode == 200 else {
                throw APIError.statusCode
            }
            return output.data
        }
        .decode(type: T.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }, receiveValue: { posts in
            //print(posts.count)
        })
        
    }
}

enum Repository {
    case local
    case remote
}

enum WebAPI {
    case fetchVideos(_ repository: Repository)
    
    var path: String {
        switch self {
        case .fetchVideos(let repo):
            switch repo {
            case .local:
                return "PlayList"
            case .remote:
                return ""
            }
        }
    }
    
    var service: VideoManagable? {
        switch self {
        case .fetchVideos(let repo):
            return VideoService(repo).videoManagable
        }
    }
}

// MARK: - Video API

struct VideoService {
    
    var videoManagable: VideoManagable?
    
    init(_ repository: Repository) {
        switch repository {
        case .local:
            videoManagable = VideoOfflineManager()
        case .remote:
            videoManagable = VideoOnlineManager()
        }
    }
    
    func getMoviesList(url: String, params: [String: String], completion: @escaping (_ response: [Video]?, _ error: APIError?)->()) {
        videoManagable?.getVideos(url: url, params: params, completion: completion)
    }
    
}

protocol VideoManagable {
    func getVideos(url: String, params: [String: String], completion: (_ response: [Video]?, _ error: APIError?)->())
}

struct VideoOnlineManager: VideoManagable, APIManagable {
    func getVideos(url: String, params: [String: String], completion: (_ response: [Video]?, _ error: APIError?)->()) {
        do {
            let request = try buildURLRequest(url, params: params)
            fetch(request, value: Video.self, completion: completion as! (Any?, APIError?) -> ())
        } catch {
            completion([Video](), error as? APIError)
        }
    }
}

struct VideoOfflineManager: VideoManagable {
    func getVideos(url: String, params: [String: String], completion: (_ response: [Video]?, _ error: APIError?)->()) {
        if let path = Bundle.main.path(forResource: url, ofType: "json") {
            do {
                  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                  print(jsonResult)
                  if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                            // do stuff
                    let decoder = JSONDecoder()
                    let jsonData = try decoder.decode(ResponseData.self, from: data)
                    completion(jsonData.data, nil)
                  }
              } catch {
                   // handle error
                completion([Video](), nil)
              }
        }
    }
}

