//
//  PhotoViewModel.swift
//  Mewx
//
//  Created by Matthew Goacher on 9/9/25.
//

import Foundation
import Photos

struct PhotoViewModel {
    let data: Data
    var date: Date
    var latitude: Double?
    var longitude: Double?
    var photographer: String = "Matt"
    var comments: String = ""
    let isVideo: Bool
    let originalWidth: Int
    let originalHeight: Int
    var uploaded: Date?
}

extension PhotoViewModel {
    /// So we can tell if we've already copied an asset in.
    struct Stamp: Equatable, Hashable, Sendable {
        let date: Date?
        let latitude: Double?
        let longitude: Double?
        let isVideo: Bool
        let pixelWidth: Int
        let pixelHeight: Int
    }
    var stamp: Stamp {
        .init(date: date, latitude: latitude, longitude: longitude, isVideo: isVideo, pixelWidth: originalWidth, pixelHeight: originalHeight)
    }
}
struct UniquePHAsset {
    init(asset: PHAsset) {
        self.asset = asset
    }
    private var _date: Date?
    var date: Date? {
        get { _date ?? asset.creationDate }
        set { _date = newValue }
    }
    let asset: PHAsset
    var stamp: PhotoViewModel.Stamp {
        .init(date: date, latitude: asset.location?.coordinate.latitude, longitude: asset.location?.coordinate.longitude, isVideo: asset.mediaType == .video, pixelWidth: asset.pixelWidth, pixelHeight: asset.pixelHeight)
    }
}
