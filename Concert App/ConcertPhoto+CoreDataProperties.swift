//
//  ConcertPhoto+CoreDataProperties.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
//

import Foundation
import CoreData

extension ConcertPhoto {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConcertPhoto> {
        return NSFetchRequest<ConcertPhoto>(entityName: "ConcertPhoto")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var photoIdentifier: String? // Local identifier from Photos library
    @NSManaged public var dateAdded: Date?
    @NSManaged public var isVideo: Bool
    @NSManaged public var concert: Concert?
    
    public var wrappedID: UUID {
        id ?? UUID()
    }
    
    public var wrappedPhotoIdentifier: String {
        photoIdentifier ?? ""
    }
    
    public var wrappedDateAdded: Date {
        dateAdded ?? Date()
    }
}

extension ConcertPhoto: Identifiable {
    
}
