//
//  InsightsViewModel.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
//

import Foundation
import CoreData
import Combine

@MainActor
class InsightsViewModel: ObservableObject {
    @Published var totalConcerts: Int = 0
    @Published var totalUniqueArtists: Int = 0
    @Published var totalUniqueVenues: Int = 0
    @Published var totalUniqueCities: Int = 0
    @Published var concertsThisYear: Int = 0
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext? = nil) {
        self.viewContext = context ?? PersistenceController.shared.container.viewContext
    }
    
    func calculateInsights() {
        totalConcerts = fetchTotalConcerts()
        totalUniqueArtists = fetchUniqueArtists()
        totalUniqueVenues = fetchUniqueVenues()
        totalUniqueCities = fetchUniqueCities()
        concertsThisYear = fetchConcertsThisYear()
    }
    
    private func fetchTotalConcerts() -> Int {
        let request = Concert.fetchRequest()
        return (try? viewContext.count(for: request)) ?? 0
    }
    
    private func fetchUniqueArtists() -> Int {
        let request = NSFetchRequest<NSDictionary>(entityName: "Artist")
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = ["name"]
        
        guard let results = try? viewContext.fetch(request) else {
            return 0
        }
        
        let uniqueNames = Set(results.compactMap { $0["name"] as? String })
        return uniqueNames.count
    }
    
    private func fetchUniqueVenues() -> Int {
        let request = NSFetchRequest<NSDictionary>(entityName: "Concert")
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = ["venueName"]
        
        guard let results = try? viewContext.fetch(request) else {
            return 0
        }
        
        let uniqueVenues = Set(results.compactMap { $0["venueName"] as? String }.filter { !$0.isEmpty })
        return uniqueVenues.count
    }
    
    private func fetchUniqueCities() -> Int {
        let request = NSFetchRequest<NSDictionary>(entityName: "Concert")
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = ["city"]
        
        guard let results = try? viewContext.fetch(request) else {
            return 0
        }
        
        let uniqueCities = Set(results.compactMap { $0["city"] as? String }.filter { !$0.isEmpty })
        return uniqueCities.count
    }
    
    private func fetchConcertsThisYear() -> Int {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now)),
              let endOfYear = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: startOfYear) else {
            return 0
        }
        
        let request = Concert.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfYear as NSDate, endOfYear as NSDate)
        
        return (try? viewContext.count(for: request)) ?? 0
    }
}
