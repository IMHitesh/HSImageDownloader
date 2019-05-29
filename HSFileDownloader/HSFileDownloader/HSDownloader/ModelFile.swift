\//
//  ModelFile.swift
//  HSFileDownloader
//
//  Created by Hitesh on 28/05/19.
//  Copyright © 2019 Hitesh. All rights reserved.
//

import Foundation


import Foundation.NSURL

// Query service creates Track objects
class ModelFileDownload {
   
    let name: String
    let previewURL: URL
//    let index: Int
    var downloaded = false
    
    init(name: String, previewURL: URL) {
        self.name = name
        self.previewURL = previewURL
//        self.index = index
    }
    
}
