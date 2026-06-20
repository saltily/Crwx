//
//  PickPhotosButton.swift
//  Mewx
//
//  Created by Matthew Goacher on 9/9/25.
//

import SwiftUI
import FoundationSalt
import Photos
import FoundationUI
import SwiftData
import os

struct PickPhotosButton: View {
    let trip: Trip
    @State private var photos: PhotosManager?
    @Environment(\.modelContext) private var context
    var body: some View {
        let day = trip.date.day
        let stamps = trip.photos?.map {
            $0.stamp
        }.set ?? []
        Button {
            self.photos = PhotosManager(dates: day.full, existing: stamps, needsUploading: needsUploading, modelContainer: context.container)
        } label: {
            Label {
                if let count = trip.photos?.count,
                   count > 0
                {
                    Text(count.appending("Photo", "Photos"))
                } else {
                    Text("Pick Photos")
                }
            } icon: {
                Image(systemName: "photo")
            }
        }
        .fullScreenCover(item: $photos) { photos in
            NavigationStack {
                PhotoBrowser(photos: photos)
                    .navigationTitle(photos.countSummary)
                    .cancelButton()
                    .saveButton {
                        await photos.saveSelected(to: trip)
                    }
                    .environment(trip)
            }
        }
    }
    private var needsUploading: Set<PersistentIdentifier> {
        guard trip.webId != nil else { return [] }
        return trip.photos?.filter {
            $0.webId == nil
        }.map {
            $0.persistentModelID
        }.set ?? []
    }
}
struct PhotoBrowser: View {
    @Bindable var photos: PhotosManager
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(),
                GridItem()
            ], spacing: 5) {
                if photos.isLoading {
                    ProgressView()
                }
                ForEach(0..<photos.assets.count, id: \.self) { i in
                    PhotoAssetThumbnail(index: i, photos: photos)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Text(message)
                .padding(.top, 10)
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Button(systemImage: "chevron.left") {
                    photos.set(dates: photos.dates.lowerBound.day.yesterday.full)
                }
                Spacer()
                Text(photos.dates.lowerBound, format: .dateTime.month(.defaultDigits).day().year(.twoDigits).weekday())
                Spacer()
                Button(systemImage: "chevron.right") {
                    photos.set(dates: photos.dates.lowerBound.day.tomorrow.full)
                }
            }
            .buttonStyle(.bordered)
            .font(.callout)
        }
    }
    private var message: String {
        let ct = photos.uploadCount
        if ct > 0 {
            return "\(photos.uploadType) \(ct.appending("photo", "photos"))…"
        }
        return "Copy \(photos.selectionSummary)"
    }
}
fileprivate struct PhotoAssetThumbnail: View {
    let index: Int
    let photos: PhotosManager
    @State private var image: UIImage?
    @Environment(Trip.self) private var trip
    var body: some View {
        let uniqueAsset = photos[index]
        let exists = photos.existing.contains(uniqueAsset.stamp)
        let asset = uniqueAsset.asset
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(exists ? 0.5 : 1)
                if asset.mediaType == .video {
                    Image(systemName: "play.circle")
                        .font(.largeTitle)
                        .opacity(0.8)
                }
                Group {
                    if exists {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Button(systemImage: "trash") {
                                Task {
                                    do {
                                        try await photos.unload(index, on: trip)
                                    } catch {
                                        logger.critical("Couldn't unsave photo: \(error)")
                                    }
                                }
                            }
                            .tint(.pink)
                        }
                    }
                    else if photos.isSelected(index) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.yellow)
                    } else {
                        Image(systemName: "circle")
                    }
                }
                .padding(5)
                .mapAlignment(.topLeading)
                if asset.location != nil {
                    Image(systemName: "mappin.and.ellipse")
                        .padding(5)
                        .mapAlignment(.topTrailing)
                }
            } else {
                ProgressView()
            }
        }
//        .aspectRatio(1.0, contentMode: .fit)
        .contentShape(Rectangle())
        .onTapGesture {
            if !exists {
                photos.toggleSelection(index)
            }
        }
        .task {
            let task = Task.detached {
                try await photos.thumbnail(asset)
            }
            do {
                self.image = try await task.value
            } catch is CancellationError {
                logger.warning("Cancelled loading thumbnail")
            } catch {
                logger.critical("Error loading thumbnail: \(error)")
            }
        }
    }
}
