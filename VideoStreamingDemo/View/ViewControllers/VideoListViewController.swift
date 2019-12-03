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

    // MARK: - Constants

    // MARK: - Instance Variables
    var viewModel = VideoViewModel()
    var cancelable: AnyCancellable?

    // MARK: - IBOutlets

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        viewModel.fetchVideos()
    }
      
    // MARK: - Helper Methods

    private func addObservers() {
       cancelable = viewModel.onFetchVideo.sink(receiveCompletion: { (error) in
        }) { [weak self] (videos) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableView DataSource

extension VideoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.videos.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoTableViewCell.cellID) as? VideoTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.setData(viewModel.videos[indexPath.row])
        return cell
    }
}

// MARK: - UITableView Delegate

extension VideoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "VideoDetailViewControlller") as? VideoDetailViewController {
            viewModel.selectedIndex = indexPath.row
            controller.viewModel = viewModel
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

