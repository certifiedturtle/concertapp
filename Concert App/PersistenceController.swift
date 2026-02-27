//
//  PersistenceController.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // Automatically find the correct model name by trying common variations
        let possibleNames = ["ConcertApp", "Concert App", "Concert_App", "ConcertModel"]
        var modelName = "ConcertApp" // default
        
        // Try to find which model file actually exists
        for name in possibleNames {
            if Bundle.main.url(forResource: name, withExtension: "momd") != nil {
                modelName = name
                print("✅ Found Core Data model: \(name)")
                break
            }
        }
        
        container = NSPersistentContainer(name: modelName)
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                // Provide more helpful error message
                print("""
                    ⚠️ Error loading Core Data: \(error.localizedDescription)
                    
                    Attempted to load model: \(modelName)
                    
                    Available .momd files in bundle:
                    \(Bundle.main.urls(forResourcesWithExtension: "momd", subdirectory: nil) ?? [])
                    
                    Make sure:
                    1. Your .xcdatamodeld file has a current version set
                    2. Codegen is set to "Manual/None" for all entities
                    3. The file is included in your target
                    """)
                fatalError("Core Data initialization failed")
            }
            print("✅ Core Data loaded successfully from: \(description.url?.lastPathComponent ?? "unknown")")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create sample data for previews
        let concert = Concert(context: viewContext)
        concert.id = UUID()
        concert.date = Date()
        concert.venueName = "Madison Square Garden"
        concert.city = "New York"
        concert.state = "NY"
        concert.concertDescription = "Amazing show!"
        concert.setlistURL = "https://www.setlist.fm"
        concert.concertType = "standard"
        concert.friendsTags = "John, Sarah"
        
        let artist = Artist(context: viewContext)
        artist.id = UUID()
        artist.name = "The Beatles"
        artist.isHeadliner = true
        artist.concert = concert
        
        try? viewContext.save()
        
        return controller
    }()
    
    // MARK: - Testing Utilities
    
    /// Clears all photo data from all concerts (for testing purposes)
    func clearAllPhotos() throws {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ConcertPhoto.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        try context.execute(deleteRequest)
        try context.save()
        
        print("✅ Cleared all photo data")
    }
    
    /// Clears all data (concerts, artists, photos) - use with caution!
    func clearAllData() throws {
        let context = container.viewContext
        
        // Delete all photos
        let photoFetchRequest: NSFetchRequest<NSFetchRequestResult> = ConcertPhoto.fetchRequest()
        let photoDeleteRequest = NSBatchDeleteRequest(fetchRequest: photoFetchRequest)
        try context.execute(photoDeleteRequest)
        
        // Delete all artists
        let artistFetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Artist")
        let artistDeleteRequest = NSBatchDeleteRequest(fetchRequest: artistFetchRequest)
        try context.execute(artistDeleteRequest)
        
        // Delete all concerts
        let concertFetchRequest: NSFetchRequest<NSFetchRequestResult> = Concert.fetchRequest()
        let concertDeleteRequest = NSBatchDeleteRequest(fetchRequest: concertFetchRequest)
        try context.execute(concertDeleteRequest)
        
        try context.save()
        
        // Reset the context
        context.reset()
        
        print("✅ Cleared all data (concerts, artists, photos)")
    }
    
    /// Returns statistics about the current data
    func getDataStats() -> (concerts: Int, artists: Int, photos: Int) {
        let context = container.viewContext
        
        let concertCount = (try? context.count(for: Concert.fetchRequest())) ?? 0
        let artistCount = (try? context.count(for: NSFetchRequest(entityName: "Artist"))) ?? 0
        let photoCount = (try? context.count(for: ConcertPhoto.fetchRequest())) ?? 0
        
        return (concerts: concertCount, artists: artistCount, photos: photoCount)
    }
}
