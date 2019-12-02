//
//  ViewController.swift
//  VideoStreamingDemo
//
//  Created by Muhammad Waqas on 28/11/2019.
//  Copyright © 2019 Muhammad Waqas. All rights reserved.
//

import UIKit
import Combine

class VideoListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var viewModel = VideoViewModel()
    var cancelable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        viewModel.fetchVideos()
    }
        
    private func addObservers() {
        
       cancelable = viewModel.onFetchVideo.sink(receiveCompletion: { (error) in
            
        }) { [weak self] (videos) in
            //
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension VideoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.videos.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoTableViewCell.cellID) as? VideoTableViewCell else {
            return UITableViewCell()
        }
        cell.setData(viewModel.videos[indexPath.row])
        return cell
    }
}

extension VideoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "VideoDetailViewControlller") as? VideoDetailViewController {
            viewModel.selectedIndex = indexPath.row
            controller.viewModel = viewModel
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
