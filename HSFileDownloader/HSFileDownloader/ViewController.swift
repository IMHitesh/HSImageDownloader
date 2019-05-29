//
//  ViewController.swift
//  HSFileDownloader
//
//  Created by Hitesh on 28/05/19.
//  Copyright © 2019 Hitesh. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation


class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var aryAllRecords: [ImageModel] = []
    
    let downloadService = DownloadService()
    
    
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    // Get local file path: download task stores tune here; AV player plays it.
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.tableFooterView = UIView()
        
        downloadService.downloadsSession = downloadsSession
        
        let firstImage : ImageModel = ImageModel.init(name: "Walter Fall", previewURL: URL.init(string:"https://s4827.pcdn.co/wp-content/uploads/2018/06/macOS_mojave_wallpaper_mid-day.jpg")!)
        
        let secondImage : ImageModel = ImageModel.init(name: "Walter Fall", previewURL: URL.init(string:"https://s4827.pcdn.co/wp-content/uploads/2018/06/macOS_mojave_wallpaper_mid-day.jpg")!)
        
        let secondImage1 : ImageModel = ImageModel.init(name: "Walter Fall", previewURL: URL.init(string:"https://s4827.pcdn.co/wp-content/uploads/2018/06/macOS_mojave_wallpaper_mid-day.jpg")!)
        
        let secondImage2 : ImageModel = ImageModel.init(name: "Walter Fall", previewURL: URL.init(string:"https://s4827.pcdn.co/wp-content/uploads/2018/06/macOS_mojave_wallpaper_mid-day.jpg")!)
        
        let secondImage3 : ImageModel = ImageModel.init(name: "Walter Fall", previewURL: URL.init(string:"https://s4827.pcdn.co/wp-content/uploads/2018/06/macOS_mojave_wallpaper_mid-day.jpg")!)
        
        let secondImage4 : ImageModel = ImageModel.init(name: "Walter Fall", previewURL: URL.init(string:"https://s4827.pcdn.co/wp-content/uploads/2018/06/macOS_mojave_wallpaper_mid-day.jpg")!)
        
        let secondImage5 : ImageModel = ImageModel.init(name: "Walter Fall", previewURL: URL.init(string:"https://www.fujifilmusa.com/products/digital_cameras/x/fujifilm_x_s1/sample_images/img/index/ff_x_s1_002.JPG")!)
        
        let secondImage6 : ImageModel = ImageModel.init(name: "Walter Fall", previewURL: URL.init(string:"https://imgsv.imaging.nikon.com/lineup/lens/f-mount/zoom/normalzoom/af-s_dx_18-300mmf_35-56g_ed_vr/img/sample/sample4_l.jpg")!)
        
        
        aryAllRecords = [firstImage, secondImage,secondImage1,secondImage2,secondImage3,secondImage4,secondImage5,secondImage6]
        
        tableView.reloadData()
        
    }
    
    func playDownload(_ track: ImageModel) {
        let playerViewController = AVPlayerViewController()
        playerViewController.entersFullScreenWhenPlaybackBegins = true
        playerViewController.exitsFullScreenWhenPlaybackEnds = true
        present(playerViewController, animated: true, completion: nil)
        let url = localFilePath(for: track.previewURL)
        let player = AVPlayer(url: url)
        playerViewController.player = player
        player.play()
    }
    
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryAllRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TrackCell = tableView.dequeueReusableCell(withIdentifier: "TrackCell") as! TrackCell
        
        // Delegate cell button tap events to this view controller
        cell.delegate = self
        
        let track = aryAllRecords[indexPath.row]
        
        cell.configure(track: track, downloaded: track.downloaded, download: downloadService.activeDownloads[track.previewURL])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62.0
    }
    
    // When user taps cell, play the local file, if it's downloaded
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = aryAllRecords[indexPath.row]
        if track.downloaded {
            playDownload(track)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: TrackCellDelegate {
    
    func downloadTapped(_ cell: TrackCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            //            cell.progressView.progress = 0.0
            let track = aryAllRecords[indexPath.row]
            downloadService.startDownload(track)
            reload(indexPath.row)
        }
    }
    
    func pauseTapped(_ cell: TrackCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let track = aryAllRecords[indexPath.row]
            downloadService.pauseDownload(track)
            reload(indexPath.row)
        }
    }
    
    func resumeTapped(_ cell: TrackCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let track = aryAllRecords[indexPath.row]
            downloadService.resumeDownload(track)
            reload(indexPath.row)
        }
    }
    
    func cancelTapped(_ cell: TrackCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let track = aryAllRecords[indexPath.row]
            downloadService.cancelDownload(track)
            reload(indexPath.row)
        }
    }
    
    // Update track cell's buttons
    func reload(_ row: Int) {
        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
}


extension ViewController: URLSessionDownloadDelegate {
    
    // Stores downloaded file
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // 1
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        let download = downloadService.activeDownloads[sourceURL]
        downloadService.activeDownloads[sourceURL] = nil
        // 2
        let destinationURL = localFilePath(for: sourceURL)
        print(destinationURL)
        // 3
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
            download?.imageDetail.downloaded = true
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        // 4
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // Updates progress info
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        // 1
        guard let url = downloadTask.originalRequest?.url,
            let download = downloadService.activeDownloads[url]
            else { return }
        // 2
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        // 3
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite,
                                                  countStyle: .file)
        // 4
        DispatchQueue.main.async {
            download.imageDetail.progress = progress
            download.imageDetail.totalSize = totalSize
            self.tableView.reloadData()
        }
    }
}

// MARK: - URLSessionDelegate
extension ViewController: URLSessionDelegate {
    // Standard background session handler
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
    
}
