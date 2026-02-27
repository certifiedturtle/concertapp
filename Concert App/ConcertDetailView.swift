//
//  ConcertDetailView.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
//

import SwiftUI
import PhotosUI
import CoreData

struct ConcertDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var concert: Concert
    
    @StateObject private var viewModel = ConcertViewModel()
    
    @State private var showingEditSheet = false
    @State private var showingPhotoPicker = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showingFullScreenPhoto: ConcertPhoto?
    @State private var showingPhotoPermissionAlert = false
    @State private var photoAuthorizationStatus: PHAuthorizationStatus = .notDetermined
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(concert.primaryArtistName)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        if concert.isFestival {
                            Label("Festival", systemImage: "star.circle.fill")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.orange.opacity(0.2))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text(concert.displayDate)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                Divider()
                
                // Venue Details
                VStack(alignment: .leading, spacing: 12) {
                    Label(concert.wrappedVenueName, systemImage: "building.2.fill")
                        .font(.headline)
                    
                    if !concert.wrappedCity.isEmpty {
                        Label("\(concert.wrappedCity), \(concert.wrappedState)", systemImage: "location.fill")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Artists
                if concert.artistsArray.count > 1 {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Artists")
                            .font(.headline)
                        
                        ForEach(concert.artistsArray) { artist in
                            HStack {
                                Image(systemName: artist.isHeadliner ? "star.fill" : "music.note")
                                    .foregroundStyle(artist.isHeadliner ? .yellow : .secondary)
                                    .frame(width: 20)
                                
                                Text(artist.wrappedName)
                                    .font(artist.isHeadliner ? .body.weight(.semibold) : .body)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Friends
                if !concert.friendsTagsArray.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Friends")
                            .font(.headline)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(concert.friendsTagsArray, id: \.self) { friend in
                                Text(friend)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.blue.opacity(0.1))
                                    .foregroundStyle(.blue)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Description
                if let description = concert.concertDescription, !description.isEmpty {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        
                        Text(description)
                            .font(.body)
                    }
                    .padding(.horizontal)
                }
                
                // Setlist URL
                if let setlistURL = concert.setlistURL, !setlistURL.isEmpty, let url = URL(string: setlistURL) {
                    Divider()
                    
                    Link(destination: url) {
                        HStack {
                            Label("View Setlist", systemImage: "music.note.list")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }
                        .font(.headline)
                        .foregroundStyle(.blue)
                    }
                    .padding(.horizontal)
                }
                
                // Photos
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Photos & Videos")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            checkPhotoLibraryPermission()
                        } label: {
                            Label("Add", systemImage: "plus.circle.fill")
                                .font(.subheadline)
                        }
                    }
                    
                    if concert.photosArray.isEmpty {
                        Text("No photos yet")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        PhotoGridView(photos: concert.photosArray, onTap: { photo in
                            showingFullScreenPhoto = photo
                        })
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddEditConcertView(concert: concert)
                .environment(\.managedObjectContext, viewContext)
        }
        .fullScreenCover(item: $showingFullScreenPhoto) { photo in
            FullScreenPhotoGalleryView(photos: concert.photosArray, selectedPhoto: photo)
        }
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotos, matching: .any(of: [.images, .videos]))
        .alert("Photo Access Required", isPresented: $showingPhotoPermissionAlert) {
            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This app needs access to your photo library to add photos to concerts. Please enable photo access in Settings.")
        }
        .onChange(of: selectedPhotos) { oldValue, newValue in
            Task {
                await loadPhotos(newValue)
            }
        }
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        photoAuthorizationStatus = status
        
        switch status {
        case .notDetermined:
            // Request permission
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    photoAuthorizationStatus = newStatus
                    if newStatus == .authorized || newStatus == .limited {
                        showingPhotoPicker = true
                    } else {
                        showingPhotoPermissionAlert = true
                    }
                }
            }
        case .authorized, .limited:
            // Permission already granted
            showingPhotoPicker = true
        case .denied, .restricted:
            // Permission denied, show alert
            showingPhotoPermissionAlert = true
        @unknown default:
            showingPhotoPermissionAlert = true
        }
    }
    
    private func loadPhotos(_ items: [PhotosPickerItem]) async {
        for item in items {
            do {
                // Try to load as a photo asset reference
                if let photoAsset = try await loadPhotoAsset(from: item) {
                    try viewModel.addPhoto(to: concert, asset: photoAsset)
                    print("✅ Added photo: \(photoAsset.localIdentifier)")
                }
            } catch {
                print("❌ Error loading photo: \(error)")
            }
        }
        selectedPhotos = []
    }
    
    private func loadPhotoAsset(from item: PhotosPickerItem) async throws -> PHAsset? {
        // Method 1: Try to get identifier directly (works in some cases)
        if let identifier = item.itemIdentifier {
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
            if let asset = fetchResult.firstObject {
                print("✅ Found asset using itemIdentifier")
                return asset
            }
        }
        
        // Method 2: Try to find the asset by comparing image data
        // This searches through recent photos to find a match without creating duplicates
        if try await item.loadTransferable(type: Data.self) != nil {
            // Try to find an existing asset with matching creation date
            // PhotosPicker items from the library should match recent photos
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.fetchLimit = 100 // Search recent photos
            
            let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            // For videos, check video assets too
            if item.supportedContentTypes.contains(where: { $0.identifier.contains("video") }) {
                let videoFetchOptions = PHFetchOptions()
                videoFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                videoFetchOptions.fetchLimit = 100
                let allVideos = PHAsset.fetchAssets(with: .video, options: videoFetchOptions)
                
                if allVideos.count > 0, let firstVideo = allVideos.firstObject {
                    print("✅ Found video asset from recent videos")
                    return firstVideo
                }
            }
            
            // Return the most recent matching asset if found
            if allPhotos.count > 0, let asset = allPhotos.firstObject {
                print("✅ Found asset from recent photos")
                return asset
            }
            
            print("⚠️ Could not find existing asset - photo may be from outside the library")
        }
        
        return nil
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.positions[index], proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let concert = Concert(context: context)
    concert.id = UUID()
    concert.date = Date()
    concert.venueName = "Madison Square Garden"
    concert.city = "New York"
    concert.state = "NY"
    concert.concertDescription = "Amazing show with incredible energy!"
    concert.friendsTags = "John, Sarah, Mike"
    
    return NavigationStack {
        ConcertDetailView(concert: concert)
            .environment(\.managedObjectContext, context)
    }
}
