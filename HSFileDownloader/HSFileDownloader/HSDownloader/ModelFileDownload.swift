//
//  ModelFile.swift
//  HSFileDownloader
//
//  Created by Hitesh on 28/05/19.
//  Copyright © 2019 Hitesh. All rights reserved.
//



import Foundation.NSURL

// Query service creates Track objects
class ImageModel {
    
    let name: String
    let previewURL: URL
    var downloaded = false
    var progress = Float(0.0)
    var totalSize = "0.0 MB"

    init(name: String, previewURL: URL) {
        self.name = name
        self.previewURL = previewURL
    }
}


// Download service creates Download objects
class Download {
    
    var imageDetail: ImageModel
    init(imageInfo: ImageModel) {
        self.imageDetail = imageInfo
    }
    
    // Download service sets these values:
    var task: URLSessionDownloadTask?
    var isDownloading = false
    var resumeData: Data?    
}
