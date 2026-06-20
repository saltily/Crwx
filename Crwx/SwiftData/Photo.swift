//
//  Photo.swift
//  Mewx
//
//  Created by Matthew Goacher on 9/9/25.
//

import Foundation
import CoreGraphics

typealias Photo = CurrentSchema.Photo

extension Photo {
    var stamp: PhotoViewModel.Stamp {
        .init(date: date, latitude: latitude, longitude: longitude, isVideo: isVideo, pixelWidth: originalWidth, pixelHeight: originalHeight)
    }
    var image: CGImage? {
        guard let data else { return nil }
        if isVideo {
            guard let imageData = videoWrapper?.imageData else { return nil }
            return .with(data: imageData)
        }
        return .with(data: data)
    }
    var videoWrapper: VideoWrapper? {
        .init(decoding: data)
    }
    struct VideoWrapper: Codable {
        let imageData: Data?
        let videoData: Data?
    }
}

extension Photo {
    var packet: WebPacket? {
        guard let tripId = trip?.webId
        else { return nil }
        return .init(
            trip_id: tripId,
            id: id.uuidString,
            harbour_id: harbour?.webId,
            timestamp: date.timeIntervalSince1970.rounded,
            latitude: latitude,
            longitude: longitude,
            photographer: photographer,
            comments: comments,
            isVideo: isVideo ? 1 : 0
        )
    }
    struct WebPacket: Encodable {
        let trip_id: Int
        let id: String
        let harbour_id: Int?
        let timestamp: Int
        let latitude: Double?
        let longitude: Double?
        let photographer: String
        let comments: String
        let isVideo: Int
    }
}
