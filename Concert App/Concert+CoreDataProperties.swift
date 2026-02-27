//
//  Concert+CoreDataProperties.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
//

import Foundation
import CoreData

extension Concert {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Concert> {
        return NSFetchRequest<Concert>(entityName: "Concert")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var venueName: String?
    @NSManaged public var city: String?
    @NSManaged public var state: String?
    @NSManaged public var concertDescription: String?
    @NSManaged public var setlistURL: String?
    @NSManaged public var concertType: String? // "standard" or "festival"
    @NSManaged public var friendsTags: String? // Comma-separated tags
    @NSManaged public var artists: NSSet?
    @NSManaged public var photos: NSSet?
    
    // Computed properties for easier access
    public var wrappedID: UUID {
        id ?? UUID()
    }
    
    public var wrappedDate: Date {
        date ?? Date()
    }
    
    public var wrappedVenueName: String {
        venueName ?? "Unknown Venue"
    }
    
    public var wrappedCity: String {
        city ?? ""
    }
    
    public var wrappedState: String {
        state ?? ""
    }
    
    public var wrappedConcertType: String {
        concertType ?? "standard"
    }
    
    public var isFestival: Bool {
        concertType == "festival"
    }
    
    public var artistsArray: [Artist] {
        let set = artists as? Set<Artist> ?? []
        return set.sorted { first, second in
            // Headliners first, then by name
            if first.isHeadliner != second.isHeadliner {
                return first.isHeadliner && !second.isHeadliner
            }
            return first.wrappedName < second.wrappedName
        }
    }
    
    public var photosArray: [ConcertPhoto] {
        let set = photos as? Set<ConcertPhoto> ?? []
        return set.sorted { ($0.dateAdded ?? Date()) > ($1.dateAdded ?? Date()) }
    }
    
    public var friendsTagsArray: [String] {
        guard let tags = friendsTags, !tags.isEmpty else { return [] }
        return tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    public var primaryArtistName: String {
        if let headliner = artistsArray.first(where: { $0.isHeadliner }) {
            return headliner.wrappedName
        }
        return artistsArray.first?.wrappedName ?? "Unknown Artist"
    }
    
    public var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: wrappedDate)
    }
}

// MARK: Generated accessors for artists
extension Concert {
    
    @objc(addArtistsObject:)
    @NSManaged public func addToArtists(_ value: Artist)
    
    @objc(removeArtistsObject:)
    @NSManaged public func removeFromArtists(_ value: Artist)
    
    @objc(addArtists:)
    @NSManaged public func addToArtists(_ values: NSSet)
    
    @objc(removeArtists:)
    @NSManaged public func removeFromArtists(_ values: NSSet)
}

// MARK: Generated accessors for photos
extension Concert {
    
    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: ConcertPhoto)
    
    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: ConcertPhoto)
    
    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)
    
    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)
}

extension Concert: Identifiable {
    
}
