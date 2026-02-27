//
//  Artist+CoreDataProperties.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
//

import Foundation
import CoreData

extension Artist {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Artist> {
        return NSFetchRequest<Artist>(entityName: "Artist")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var isHeadliner: Bool
    @NSManaged public var concert: Concert?
    
    public var wrappedID: UUID {
        id ?? UUID()
    }
    
    public var wrappedName: String {
        name ?? "Unknown Artist"
    }
}

extension Artist: Identifiable {
    
}
