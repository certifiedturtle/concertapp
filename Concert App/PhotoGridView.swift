//
//  PhotoGridView.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
//

import SwiftUI
import Photos
import CoreData

struct PhotoGridView: View {
    let photos: [ConcertPhoto]
    let onTap: (ConcertPhoto) -> Void
    
    let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 4)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(photos) { photo in
                PhotoThumbnailView(photo: photo)
                    .frame(minHeight: 100, maxHeight: 150)
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture {
                        onTap(photo)
                    }
            }
        }
    }
}

struct PhotoThumbnailView: View {
    let photo: ConcertPhoto
    @State private var image: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    Color.gray.opacity(0.3)
                    ProgressView()
                }
                
                if photo.isVideo {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .shadow(radius: 2)
                                .padding(8)
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        let fetchResult = PHAsset.fetchAssets(
            withLocalIdentifiers: [photo.wrappedPhotoIdentifier],
            options: nil
        )
        
        guard let asset = fetchResult.firstObject else { return }
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        
        manager.requestImage(
            for: asset,
            targetSize: CGSize(width: 200, height: 200),
            contentMode: .aspectFill,
            options: options
        ) { result, _ in
            self.image = result
        }
    }
}

struct FullScreenPhotoView: View {
    @Environment(\.dismiss) private var dismiss
    let photo: ConcertPhoto
    
    @State private var image: UIImage?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
                    .tint(.white)
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            loadFullSizeImage()
        }
    }
    
    private func loadFullSizeImage() {
        let fetchResult = PHAsset.fetchAssets(
            withLocalIdentifiers: [photo.wrappedPhotoIdentifier],
            options: nil
        )
        
        guard let asset = fetchResult.firstObject else { return }
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        manager.requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: options
        ) { result, _ in
            self.image = result
        }
    }
}
// Swipeable gallery view for multiple photos
struct FullScreenPhotoGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    let photos: [ConcertPhoto]
    let selectedPhoto: ConcertPhoto
    let onDelete: ((ConcertPhoto) -> Void)?
    
    @State private var currentIndex: Int = 0
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                    FullScreenPhotoContent(photo: photo)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            VStack {
                HStack {
                    // Delete button
                    if onDelete != nil {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Image(systemName: "trash.circle.fill")
                                .font(.title)
                                .foregroundStyle(.red)
                                .shadow(radius: 3)
                                .padding()
                        }
                    }
                    
                    Spacer()
                    
                    // Close button
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .shadow(radius: 3)
                            .padding()
                    }
                }
                Spacer()
                
                // Page indicator
                if photos.count > 1 {
                    Text("\(currentIndex + 1) / \(photos.count)")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.black.opacity(0.5))
                        .clipShape(Capsule())
                        .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            // Set initial index to selected photo
            if let index = photos.firstIndex(where: { $0.id == selectedPhoto.id }) {
                currentIndex = index
            }
        }
        .alert("Delete Photo?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteCurrentPhoto()
            }
        } message: {
            Text("This will remove the photo from this concert. Your photo library will not be affected.")
        }
    }
    
    private func deleteCurrentPhoto() {
        guard currentIndex < photos.count else { return }
        let photoToDelete = photos[currentIndex]
        
        print("🗑️ User confirmed deletion of photo at index \(currentIndex)")
        
        // Call the deletion callback
        onDelete?(photoToDelete)
        
        // Always dismiss back to concert details after deletion
        print("   Returning to concert details")
        dismiss()
    }
}

// Content view for a single photo in the gallery
struct FullScreenPhotoContent: View {
    let photo: ConcertPhoto
    @State private var image: UIImage?
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                lastScale = scale
                                // Reset if zoomed out too much
                                if scale < 1.0 {
                                    withAnimation {
                                        scale = 1.0
                                        lastScale = 1.0
                                    }
                                }
                                // Limit max zoom
                                if scale > 5.0 {
                                    withAnimation {
                                        scale = 5.0
                                        lastScale = 5.0
                                    }
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        // Double-tap to reset zoom
                        withAnimation {
                            scale = 1.0
                            lastScale = 1.0
                        }
                    }
            } else {
                ProgressView()
                    .tint(.white)
            }
        }
        .onAppear {
            loadFullSizeImage()
        }
    }
    
    private func loadFullSizeImage() {
        let fetchResult = PHAsset.fetchAssets(
            withLocalIdentifiers: [photo.wrappedPhotoIdentifier],
            options: nil
        )
        
        guard let asset = fetchResult.firstObject else { return }
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        manager.requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: options
        ) { result, _ in
            self.image = result
        }
    }
}

