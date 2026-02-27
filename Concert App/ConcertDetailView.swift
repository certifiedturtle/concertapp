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
    
    @State private var showingEditSheet = false
    @State private var showingPhotoPicker = false
    @State private var showingFullScreenPhoto: ConcertPhoto?
    @State private var showingPhotoPermissionAlert = false
    @State private var photoAuthorizationStatus: PHAuthorizationStatus = .notDetermined
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
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
                } else {
                    // Show search button when no setlist URL exists
                    Divider()
                    
                    Button {
                        searchForSetlist()
                    } label: {
                        HStack {
                            Label("Search for Setlist", systemImage: "magnifyingglass")
                            Spacer()
                            Image(systemName: "safari")
                                .font(.caption)
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
            FullScreenPhotoGalleryView(
                photos: concert.photosArray,
                selectedPhoto: photo,
                onDelete: { photoToDelete in
                    deletePhoto(photoToDelete)
                }
            )
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPickerView { assets in
                addPhotos(assets)
            }
        }
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
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func searchForSetlist() {
        // Build search query with available information only
        var searchComponents: [String] = ["setlist"]
        
        // Add artist name (always available via primaryArtistName)
        searchComponents.append(concert.primaryArtistName)
        
        // Add venue name if it's not empty or default
        let venueName = concert.wrappedVenueName
        if !venueName.isEmpty && venueName != "Unknown Venue" {
            searchComponents.append(venueName)
        }
        
        // Add date if available - format as readable date
        if let date = concert.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy" // e.g., "August 2015"
            let dateString = dateFormatter.string(from: date)
            searchComponents.append(dateString)
        }
        
        // Combine into search query
        let searchQuery = searchComponents.joined(separator: " ")
        
        // URL encode and create Google search URL
        if let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://www.google.com/search?q=\(encodedQuery)") {
            UIApplication.shared.open(url)
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
    
    private func addPhotos(_ assets: [PHAsset]) {
        print("\n🎬 Adding \(assets.count) photo(s)...")
        var successCount = 0
        var failCount = 0
        
        for (index, asset) in assets.enumerated() {
            do {
                print("📸 Processing photo \(index + 1): \(asset.localIdentifier)")
                
                // Check if this photo is already added to avoid duplicates
                let existingPhotoIds = concert.photosArray.map { $0.wrappedPhotoIdentifier }
                if !existingPhotoIds.contains(asset.localIdentifier) {
                    try addPhoto(to: concert, asset: asset)
                    print("✅ Added photo \(index + 1)")
                    successCount += 1
                } else {
                    print("⚠️ Photo \(index + 1) already exists, skipping")
                }
            } catch {
                print("❌ Error saving photo \(index + 1): \(error)")
                failCount += 1
            }
        }
        
        print("\n✨ Finished: \(successCount) added, \(failCount) failed")
        
        // Show error if all failed
        if failCount > 0 && successCount == 0 {
            errorMessage = "Could not add photos. Error: \(failCount) photos failed to save."
            showingErrorAlert = true
        }
        
        // Force view refresh
        viewContext.refreshAllObjects()
    }
    
    private func addPhoto(to concert: Concert, asset: PHAsset) throws {
        let photo = ConcertPhoto(context: viewContext)
        photo.id = UUID()
        photo.photoIdentifier = asset.localIdentifier
        photo.dateAdded = Date()
        photo.isVideo = asset.mediaType == .video
        
        // Use the inverse relationship method
        concert.addToPhotos(photo)
        
        try viewContext.save()
        print("💾 Saved photo to Core Data")
    }
    
    private func deletePhoto(_ photo: ConcertPhoto) {
        print("🗑️ Deleting photo reference: \(photo.wrappedPhotoIdentifier)")
        
        // Remove from concert relationship
        concert.removeFromPhotos(photo)
        
        // Delete from Core Data
        viewContext.delete(photo)
        
        do {
            try viewContext.save()
            print("✅ Photo reference deleted successfully")
            print("   Photo count is now: \(concert.photosArray.count)")
            
            // Force view refresh
            viewContext.refreshAllObjects()
        } catch {
            print("❌ Error deleting photo: \(error)")
            errorMessage = "Could not delete photo. Please try again."
            showingErrorAlert = true
        }
    }
}

// MARK: - Photo Picker Wrapper

struct PhotoPickerView: UIViewControllerRepresentable {
    let onPhotosSelected: ([PHAsset]) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 0 // 0 = unlimited
        configuration.filter = .any(of: [.images, .videos])
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView
        
        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard !results.isEmpty else {
                print("📷 Photo picker cancelled")
                return
            }
            
            print("📷 Selected \(results.count) items from picker")
            
            // Extract asset identifiers from results
            var assets: [PHAsset] = []
            
            for result in results {
                // Get the asset identifier
                if let assetIdentifier = result.assetIdentifier {
                    print("   Found asset ID: \(assetIdentifier)")
                    let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
                    if let asset = fetchResult.firstObject {
                        assets.append(asset)
                        print("   ✅ Loaded asset: \(asset.mediaType == .image ? "image" : "video"), \(asset.pixelWidth)x\(asset.pixelHeight)")
                    } else {
                        print("   ⚠️ Could not fetch asset for identifier")
                    }
                } else {
                    print("   ⚠️ Result has no asset identifier")
                }
            }
            
            print("📷 Successfully loaded \(assets.count) of \(results.count) assets")
            parent.onPhotosSelected(assets)
        }
    }
}

// MARK: - Flow Layout

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
