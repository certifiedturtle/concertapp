//
//  ConcertViewModel.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
//

import Foundation
import CoreData
import Photos
import SwiftUI
import Combine

@MainActor
class ConcertViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext? = nil) {
        self.viewContext = context ?? PersistenceController.shared.container.viewContext
    }
    
    // MARK: - Create
    
    func createConcert(
        date: Date,
        venueName: String,
        city: String,
        state: String,
        description: String,
        setlistURL: String,
        concertType: String,
        friendsTags: String,
        artists: [(name: String, isHeadliner: Bool)]
    ) throws {
        let concert = Concert(context: viewContext)
        concert.id = UUID()
        concert.date = date
        concert.venueName = venueName
        concert.city = city
        concert.state = state
        concert.concertDescription = description
        concert.setlistURL = setlistURL
        concert.concertType = concertType
        concert.friendsTags = friendsTags
        
        // Create artists
        for artistInfo in artists {
            let artist = Artist(context: viewContext)
            artist.id = UUID()
            artist.name = artistInfo.name
            artist.isHeadliner = artistInfo.isHeadliner
            artist.concert = concert
        }
        
        try viewContext.save()
    }
    
    // MARK: - Update
    
    func updateConcert(
        _ concert: Concert,
        date: Date,
        venueName: String,
        city: String,
        state: String,
        description: String,
        setlistURL: String,
        concertType: String,
        friendsTags: String,
        artists: [(name: String, isHeadliner: Bool)]
    ) throws {
        concert.date = date
        concert.venueName = venueName
        concert.city = city
        concert.state = state
        concert.concertDescription = description
        concert.setlistURL = setlistURL
        concert.concertType = concertType
        concert.friendsTags = friendsTags
        
        // Remove old artists
        if let existingArtists = concert.artists as? Set<Artist> {
            for artist in existingArtists {
                viewContext.delete(artist)
            }
        }
        
        // Create new artists
        for artistInfo in artists {
            let artist = Artist(context: viewContext)
            artist.id = UUID()
            artist.name = artistInfo.name
            artist.isHeadliner = artistInfo.isHeadliner
            artist.concert = concert
        }
        
        try viewContext.save()
    }
    
    // MARK: - Delete
    
    func deleteConcert(_ concert: Concert) throws {
        viewContext.delete(concert)
        try viewContext.save()
    }
    
    // MARK: - Photos
    
    func addPhoto(to concert: Concert, asset: PHAsset) throws {
        let photo = ConcertPhoto(context: viewContext)
        photo.id = UUID()
        photo.photoIdentifier = asset.localIdentifier
        photo.dateAdded = Date()
        photo.isVideo = asset.mediaType == .video
        
        // Use the inverse relationship method instead of direct assignment
        concert.addToPhotos(photo)
        
        try viewContext.save()
    }
    
    func removePhoto(_ photo: ConcertPhoto) throws {
        viewContext.delete(photo)
        try viewContext.save()
    }
}
