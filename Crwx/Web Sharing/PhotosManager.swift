//
//  PhotosManager.swift
//  Mewx
//
//  Created by Matthew Goacher on 9/9/25.
//

import Foundation
import Photos
import FoundationSalt
import UIKit
import SwiftData
import os
import FoundationUI

@Observable
final class PhotosManager: Identifiable, RandomAccessCollection {
    var id: Range<Date> { dates }
    init(dates: Range<Date>, existing: Set<PhotoViewModel.Stamp>, needsUploading: Set<PersistentIdentifier>, modelContainer: ModelContainer) {
        self.dates = dates
        self.existing = existing
        self.needsUploading = needsUploading
        self.actor = .init(modelContainer: modelContainer)
        self.requestAuthorization()
    }
    private(set) var dates: Range<Date>
    var existing: Set<PhotoViewModel.Stamp>
    var needsUploading: Set<PersistentIdentifier>
    private(set) var assets: [UniquePHAsset] = []
    var selection: Set<Int> = []
    var tasks = Set<Task<(PersistentIdentifier,PhotoViewModel.Stamp?),Error>>()
    var uploadCount: Int {
        tasks.count
    }
    var uploadType: String = "Saving"
    var isLoading = false
    fileprivate let actor: PhotoActor
    var startIndex: Int { 0 }
    var endIndex: Int { assets.count }
    subscript(position: Int) -> UniquePHAsset {
        assets[position]
    }
    func set(dates: Range<Date>) {
        guard uploadCount == 0,
              isLoading == false
        else { return }
        self.dates = dates
        requestAuthorization()
    }
    private func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .notDetermined:
                logger.warning("Can't determine photo access")
            case .restricted, .denied:
                logger.critical("Photo access restricted or denied")
            case .authorized, .limited:
                self.fetchPhotos()
            @unknown default:
                logger.critical("Unknown photo access")
            }
        }
    }
    private func fetchPhotos() {
        self.isLoading = true
        let options = PHFetchOptions()
        let dates = self.dates
        options.predicate = .init(format: "creationDate >= %@ AND creationDate < %@", dates.lowerBound as CVarArg, dates.upperBound as CVarArg)
        options.sortDescriptors = [.init(key: "creationDate", ascending: true)]
        let result = PHAsset.fetchAssets(with: options)
        logger.trace("Found \(result.count) photos")
        var assets = [UniquePHAsset]()
        result.enumerateObjects { asset, index, stop in
            assets.append(.init(asset: asset))
//            let media = switch asset.mediaType {
//            case .image: "Image"
//            case .video: "Video"
//            case .audio: "Audio"
//            case .unknown: "Unknown"
//            @unknown default: "New"
//            }
//            logger.trace("Asset \(index): \(describing(asset.creationDate)), \(describing(asset.location?.coordinate)), \(media), \(asset.pixelWidth)x\(asset.pixelHeight)")
        }
//        self.selection = (0..<assets.count).map { $0 }.set
        var countUniqueDates = assets.compactMap {
            $0.date
        }.set.count
        logger.info("There are \(countUniqueDates) unique creation dates")
        if countUniqueDates < assets.count {
            // 1. What dates need to be deduplicated?
            let countedSet = assets.map { $0.date }.countedSet
            let doubleDates: [Date?] = countedSet.filter {
                countedSet.count(for: $0) > 1
            }
            logger.warning("More than one for date \(doubleDates)")
            for d in doubleDates {
                for (i, asset) in assets.enumerated() {
                    if let d,
                       asset.date == d
                    {
                        var copy = asset
                        copy.date = d.addingTimeInterval(0.1*i.double)
                        assets[i] = copy
                    }
                }
            }
        }
        countUniqueDates = assets.compactMap {
            $0.date
        }.set.count
        assert(countUniqueDates == assets.count)
        self.assets = assets
        resetSelection()
        self.isLoading = false
    }
    func resetSelection() {
        selection = selection.filter {
            !existing.contains(assets[$0].stamp)
        }.set
    }
    func thumbnail(_ asset: PHAsset) async throws -> UIImage {
        try await actor.thumbnail(asset)
    }
    func isSelected(_ i: Int) -> Bool {
        selection.contains(i)
    }
    func toggleSelection(_ i: Int) {
        if selection.contains(i) {
            selection.remove(i)
        } else {
            selection.insert(i)
        }
    }
    var countSummary: String {
        let countPhotos = assets.count(where: {
            $0.asset.mediaType == .image
        }).appending("Photo", "Photos")
        let countVideos = assets.count(where: {
            $0.asset.mediaType == .video
        })
        if countVideos == 0 {
            return countPhotos
        } else {
            return "\(countPhotos), \(countVideos.appending("Video", "Videos"))"
        }
    }
    var selectionSummary: String {
        let countPhotos = selection.count(where: {
            assets[$0].asset.mediaType == .image
        }).appending("Photo", "Photos")
        let countVideos = selection.count(where: {
            assets[$0].asset.mediaType == .video
        })
        if countVideos == 0 {
            return countPhotos
        } else {
            return "\(countPhotos), \(countVideos.appending("Video", "Videos"))"
        }
    }
    func saveSelected(to trip: Trip) async {
        await withCheckedContinuation { continuation in
            let tripId = trip.persistentModelID
            let actor = self.actor
            let isShared = trip.webId != nil
            uploadType = isShared ? "Uploading" : "Saving"
            for i in selection {
                let asset = assets[i]
                let task = Task.detached {
                    let (id, stamp) = try await actor.save(asset: asset, to: tripId)
                    if isShared {
                        let url = try await actor.upload(photoId: id)
                        await logger.info("Uploaded the photo to \(url)")
                    }
                    return (id, stamp)
                }
                tasks.insert(task)
            }
            for id in needsUploading {
                let task = Task.detached {
                    let url = try await actor.upload(photoId: id)
                    await logger.info("Uploaded the photo to \(url)")
                    return (id, nil as PhotoViewModel.Stamp?)
                }
                tasks.insert(task)
            }
            var existing = self.existing
            for task in tasks {
                Task {
                    do {
                        let (id, stamp) = try await task.value
                        if let stamp {
                            existing.insert(stamp)
                        }
                        needsUploading.remove(id)
                        tasks.remove(task)
                        if tasks.isEmpty {
                            self.existing = existing
                            resetSelection()
                            continuation.resume()
                        }
//                        logger.trace("Saved one")
                    } catch {
                        logger.critical("Couldn't save photo: \(error)")
                        tasks.remove(task)
                        if tasks.isEmpty {
                            self.existing = existing
                            resetSelection()
                            continuation.resume()
                        }
                    }
                }
            }
        }
    }
    func unload(_ i: Int, on trip: Trip) async throws {
        try await actor.unsave(asset: assets[i], on: trip.persistentModelID)
        existing.remove(assets[i].stamp)
    }
//    func upload(photo id: PersistentIdentifier) async throws {
//        let url = try await actor.upload(photoId: id)
//        url.absoluteString.copyToPasteboard()
//        logger.info("Uploaded the photo to \(url)")
//    }
}
fileprivate final actor PhotoActor {
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
    }
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    public subscript<T>(id: PersistentIdentifier, as as: T.Type) -> T? where T : PersistentModel {
        modelContext.model(for: id) as? T
    }
    let maxMegabytes = 25
    func upload(photoId: PersistentIdentifier) async throws -> URL {
        guard let photo = self[photoId, as: Photo.self]
        else { throw E.BadId }
        guard photo.uploaded == nil
        else { throw E.AlreadyUploaded }
        
        guard photo.trip?.webId != nil,
              let packet = photo.packet
        else { throw E.TripNotShared }
        
        guard let image = await photo.image
        else { throw E.NoImage }
        
        var multipart = await MultipartRequest()
        await multipart.add(key: "metadata", value: packet.jsonText)
        let web = try image.resize(to: .init(width: image.width, height: image.height).fit(max: 2048, allowsZoom: true))
        let square = try image.cropSquare()
        let url: URL
        await multipart.add(
            key: "full_size",
            fileName: "\(photo.id.uuidString)-full_size.jpg",
            fileMimeType: "image/jpeg",
            fileData: try web.jpegData(compressionQuality: 0.8)
        )
        multipart.add(
            key: "thumbnail",
            fileName: "\(photo.id.uuidString)-thumb.jpg",
            fileMimeType: "image/jpeg",
            fileData: try square.resize(to: .init(width: 320, height: 320)).jpegData(compressionQuality: 0.5)
        )
        multipart.add(
            key: "map_bubble",
            fileName: "\(photo.id.uuidString)-map_bubble.jpg",
            fileMimeType: "image/jpeg",
            fileData: try square.resize(to: .init(width: 72, height: 72)).jpegData(compressionQuality: 0.5)
        )
        if photo.isVideo {
            if let data = await photo.videoWrapper?.videoData {
                multipart.add(
                    key: "video",
                    fileName: "\(photo.id.uuidString)-full_size.mp4",
                    fileMimeType: "video/mp4",
                    fileData: data
                )
            }
            url = URL(string: "https://www.saltily.com/blouse/upload-video")!
        } else {
            //            multipart.add(
            //                key: "original",
            //                fileName: "\(photo.id.uuidString)-original.jpg",
            //                fileMimeType: "image/jpeg",
            //                fileData: try image.jpegData(compressionQuality: 1.0)
            //            )
            multipart.add(
                key: "blur",
                fileName: "\(photo.id.uuidString)-blur.jpg",
                fileMimeType: "image/jpeg",
                fileData: try web.blur().jpegData(compressionQuality: 0.1)
            )
            url = URL(string: "https://www.saltily.com/blouse/upload-photo")!
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(multipart.httpContentTypeHeadeValue, forHTTPHeaderField: "Content-Type")
        request.httpBody = multipart.httpBody
        let dataSize = request.httpBody!.count
        guard dataSize < (maxMegabytes * 1024 * 1024)
        else { throw E.ExceedsUploadLimit(dataSize.formatted(.byteCount(style: .file))) }
        logger.trace("The size of the request is \(request.httpBody!.count.formatted(.byteCount(style: .file)))")
        
//        logger.trace("Begin uploading photo(s)")
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let result = try WebShareResult(json: data)
        else {
            if let string = String(data: data, encoding: .utf8) {
                logger.trace("\(string)")
            }
            throw WebShareResult.E.InvalidResponse
        }
        if let error = result.error {
            throw WebShareResult.E.Online(error)
        }
        guard let id = result.id
        else { throw WebShareResult.E.InvalidResponse }
        photo.webId = id
        photo.uploaded = .now
        try modelContext.save()
        return URL(string: "https://www.saltily.com/blouse/photo?id=\(id)")!
    }
    func unsave(asset: UniquePHAsset, on tripId: PersistentIdentifier) async throws {
        guard let trip = self[tripId, as: Trip.self]
        else { throw E.BadId }
        if let photo = trip.photos?.first(where: {
            $0.stamp == asset.stamp
        }) {
            // first confirm removing it from online
            if let webId = photo.webId {
                let url = URL(string: "https://www.saltily.com/blouse/delete-photo")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = ["id": webId].json
                let (data, _) = try await URLSession.shared.data(for: request)
                guard let result = try WebShareResult(json: data)
                else {
                    if let string = String(data: data, encoding: .utf8) {
                        logger.trace("\(string)")
                    }
                    throw WebShareResult.E.InvalidResponse
                }
                if let error = result.error {
                    throw WebShareResult.E.Online(error)
                }
                guard let success = result.success
                else { throw WebShareResult.E.InvalidResponse }
                logger.trace("\(success)")
            }
            // then remove it locally
            trip.remove(child: photo, from: \.photos)
            modelContext.delete(photo)
            try modelContext.save()
        }
    }
    func save(asset: UniquePHAsset, to tripId: PersistentIdentifier) async throws -> (photoId: PersistentIdentifier, photoStamp: PhotoViewModel.Stamp?) {
        guard let trip = self[tripId, as: Trip.self]
        else { throw E.BadId }
        guard let date = asset.date
        else { throw E.NoDate }
        let asset = asset.asset
        let data: Data?
        if asset.mediaType == .image {
            let image = try await loadImage(asset, size: .init(width: 2048, height: 2048))
            //            let image = try await loadImage(asset, size: .init(width: asset.pixelWidth, height: asset.pixelHeight))
            data = image.heicData()
        }
        else if asset.mediaType == .video {
            let image = try await loadImage(asset, size: .init(width: 2048, height: 2048))
            let videoAsset = try await loadVideo(asset)
            let url = try await convertVideo(videoAsset, includeAudio: true)
            logger.info("The converted video is \(url.fileSize.formatted(.byteCount(style: .file))) on disc")
            data = Photo.VideoWrapper(imageData: image.heicData(), videoData: try Data(contentsOf: url)).encoded
            try FileManager.default.removeItem(at: url)
        }
        else {
            throw E.UnsupportedMedia
        }
        let photo = Photo(
            id: .init(),
            date: date,
            data: data,
            latitude: asset.location?.coordinate.latitude,
            longitude: asset.location?.coordinate.longitude,
            photographer: "Matt",
            comments: "",
            isVideo: asset.mediaType == .video,
            originalWidth: asset.pixelWidth,
            originalHeight: asset.pixelHeight
        )
        modelContext.insert(photo)
        photo.trip = trip
        trip.add(child: photo, to: \.photos)
        if let location = asset.location,
           let harbour = harbour(near: location)
        {
            photo.harbour = harbour
            harbour.add(child: photo, to: \.photos)
//            logger.trace("The harbour should be \(describing(harbour.webId)) \(harbour.name))")
        }
        try modelContext.save()
        return (photo.persistentModelID, photo.stamp)
    }
    
    func thumbnail(_ asset: PHAsset) async throws -> UIImage {
        try await loadImage(asset, size: .init(width: 160, height: 160))
    }
    func loadImage(_ asset: PHAsset, size: CGSize) async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            //            var requestID: PHImageRequestID?
            // requestId = …requestImage()
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            var isConsumed = false
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFit,
                options: options,
                resultHandler: { image, info in
                    guard !isConsumed else { return }
                    if let error = info?[PHImageErrorKey] as? Error {
                        isConsumed = true
                        continuation.resume(throwing: error)
                    }
                    else if let isCancelled = info?[PHImageCancelledKey] as? Bool,
                            isCancelled
                    {
                        isConsumed = true
                        continuation.resume(throwing: CancellationError())
                    }
                    else if let image = image,
                            !(info?[PHImageResultIsDegradedKey] as? Bool ?? false)
                    {
                        isConsumed = true
                        continuation.resume(returning: image)
                    }
                    // it'll call again if it has to
//                    else {
//                        continuation.resume(throwing: E.NoImage)
//                    }
                })
            // no idea if this bit will work
            //            Task {
            //                let _ = await Task.isCancelled
            //                if let id = requestID {
            //                    PHImageManager.default().cancelImageRequest(id)
            //                }
            //            }
        }
    }
    func loadVideo(_ asset: PHAsset) async throws -> AVAsset {
        try await withCheckedThrowingContinuation { continuation in
            //            var requestID: PHImageRequestID?
            // requestId = …requestImage()
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestAVAsset(
                forVideo: asset,
                options: options) { video, audio, info in
                    if let error = info?[PHImageErrorKey] as? Error {
                        continuation.resume(throwing: error)
                    }
                    else if let isCancelled = info?[PHImageCancelledKey] as? Bool,
                            isCancelled
                    {
                        continuation.resume(throwing: CancellationError())
                    }
                    else if let video = video
                    {
                        continuation.resume(returning: video)
                    }
                    else {
                        continuation.resume(throwing: E.NoImage)
                    }
                }
            // no idea if this bit will work
            //            Task {
            //                let _ = await Task.isCancelled
            //                if let id = requestID {
            //                    PHImageManager.default().cancelImageRequest(id)
            //                }
            //            }
        }
    }
    func convertVideo(_ asset: AVAsset, includeAudio: Bool) async throws -> URL {
        let preset = AVAssetExportPresetPassthrough
        guard await AVAssetExportSession.compatibility(ofExportPreset: preset, with: asset, outputFileType: .mp4)
        else { throw E.UnsupportedMedia }
        let exportSession: AVAssetExportSession?
        if !includeAudio {
            let composition = AVMutableComposition()
            guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first,
                  let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            else { throw E.UnsupportedMedia }
            let timeRange = try await videoTrack.load(.timeRange)
            try compositionVideoTrack.insertTimeRange(timeRange, of: videoTrack, at: .zero)
            exportSession = AVAssetExportSession(asset: composition, presetName: preset)
        }
        else {
            exportSession = AVAssetExportSession(asset: asset, presetName: preset)
        }
        guard let exportSession else { throw E.NoConversion }
        guard let location = (exportSession.directoryForTemporaryFiles ?? FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first)?.appendingPathComponent(UUID().uuidString, conformingTo: .mpeg4Movie)
        else { throw E.NoTempDirectory }
        try await exportSession.export(to: location, as: .mp4)
        return location
    }
    lazy var harboursCache: [Harbour] = {
        do {
            return try modelContext.fetch(Harbour.self)
        } catch {
            logger.critical("Couldn't get harbours: \(error)")
            return []
        }
    }()
    private func harbour(near point: any Mappable) -> Harbour? {
        let harbours = harboursCache.sorted {
            $0.distance(to: point) < $1.distance(to: point)
        }
        guard let first = harbours.first,
              first.distance(to: point).converted(to: .nauticalMiles).value < 1
        else { return nil }
        return first
    }
    enum E: Error {
        case NoImage
        case BadId
        case NoDate
        case UnsupportedMedia
        case NoConversion
        case NoTempDirectory
        case TripNotShared
        case AlreadyUploaded
        case ExceedsUploadLimit(String)
    }
}


// MARK: Multipart
public struct MultipartRequest {
    
    public let boundary: String
    
    private let separator: String = "\r\n"
    private var data: Data

    public init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
        self.data = .init()
    }
    
    private mutating func appendBoundarySeparator() {
        data.append("--\(boundary)\(separator)")
    }
    
    private mutating func appendSeparator() {
        data.append(separator)
    }

    private func disposition(_ key: String) -> String {
        "Content-Disposition: form-data; name=\"\(key)\""
    }

    public mutating func add(
        key: String,
        value: String
    ) {
        appendBoundarySeparator()
        data.append(disposition(key) + separator)
        appendSeparator()
        data.append(value + separator)
    }

    public mutating func add(
        key: String,
        fileName: String,
        fileMimeType: String,
        fileData: Data
    ) {
        appendBoundarySeparator()
        data.append(disposition(key) + "; filename=\"\(fileName)\"" + separator)
        data.append("Content-Type: \(fileMimeType)" + separator + separator)
        data.append(fileData)
        appendSeparator()
    }

    public var httpContentTypeHeadeValue: String {
        "multipart/form-data; boundary=\(boundary)"
    }

    public var httpBody: Data {
        var bodyData = data
        bodyData.append("--\(boundary)--")
        return bodyData
    }
}
fileprivate extension Data {

    mutating func append(
        _ string: String,
        encoding: String.Encoding = .utf8
    ) {
        guard let data = string.data(using: encoding) else {
            return
        }
        append(data)
    }
}
