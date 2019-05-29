

import Foundation


class DownloadService {
  
  var downloadsSession: URLSession!
  var activeDownloads: [URL: Download] = [:]
  
  // MARK: - Download methods called by TrackCell delegate methods
  
  func startDownload(_ modelFile: ImageModel) {
    // 1
    let download = Download(imageInfo: modelFile)
    // 2
    
    download.task = downloadsSession.downloadTask(with: download.imageDetail.previewURL)
    // 3
    download.task!.resume()
    // 4
    download.isDownloading = true
    // 5
    activeDownloads[download.imageDetail.previewURL] = download
  }
  
  func pauseDownload(_ track: ImageModel) {
    guard let download = activeDownloads[track.previewURL] else { return }
    if download.isDownloading {
      download.task?.cancel(byProducingResumeData: { data in
        download.resumeData = data
      })
      download.isDownloading = false
    }
  }
  
  func cancelDownload(_ modelFile: ImageModel) {
    if let download = activeDownloads[modelFile.previewURL] {
      download.task?.cancel()
      activeDownloads[modelFile.previewURL] = nil
    }
  }
  
  func resumeDownload(_ modelFile: ImageModel) {
    guard let download = activeDownloads[modelFile.previewURL] else { return }
    if let resumeData = download.resumeData {
      download.task = downloadsSession.downloadTask(withResumeData: resumeData)
    } else {
      download.task = downloadsSession.downloadTask(with: download.imageDetail.previewURL)
    }
    download.task!.resume()
    download.isDownloading = true
  }
}
