//
//  VenueListView.swift
//  Concert App
//
//  Created by Michael Tempestini on 3/1/26.
//

import SwiftUI
import CoreData

struct VenueWithCount: Identifiable {
    let id = UUID()
    let name: String
    let city: String
    let state: String
    let showCount: Int
}

struct VenueListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Concert.date, ascending: false)],
        animation: .default)
    private var concerts: FetchedResults<Concert>
    
    @State private var searchText = ""
    
    // Build venue list with counts, sorted by count (highest to lowest)
    var allVenues: [VenueWithCount] {
        var venueCounts: [String: (city: String, state: String, count: Int)] = [:]
        
        for concert in concerts {
            // Only count standard concerts with venues
            if !concert.isFestival && !concert.wrappedVenueName.isEmpty && concert.wrappedVenueName != "Unknown Venue" {
                let key = "\(concert.wrappedVenueName)|\(concert.wrappedCity)|\(concert.wrappedState)"
                if var existing = venueCounts[key] {
                    existing.count += 1
                    venueCounts[key] = existing
                } else {
                    venueCounts[key] = (
                        city: concert.wrappedCity,
                        state: concert.wrappedState,
                        count: 1
                    )
                }
            }
        }
        
        return venueCounts.map { key, value in
            let parts = key.split(separator: "|")
            return VenueWithCount(
                name: String(parts[0]),
                city: value.city,
                state: value.state,
                showCount: value.count
            )
        }
        .sorted { $0.showCount > $1.showCount }
    }
    
    var filteredVenues: [VenueWithCount] {
        if searchText.isEmpty {
            return allVenues
        }
        return allVenues.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.city.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredVenues) { venue in
                NavigationLink(destination: VenueDetailView(venueName: venue.name, venueCity: venue.city, venueState: venue.state, concerts: Array(concerts))) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(venue.name)
                            .font(.headline)
                        
                        if !venue.city.isEmpty {
                            Text("\(venue.city), \(venue.state)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("\(venue.showCount) show\(venue.showCount == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Venues")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search venues")
        .overlay {
            if filteredVenues.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: searchText.isEmpty ? "building.2.slash" : "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    Text(searchText.isEmpty ? "No Venues" : "No Results")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(searchText.isEmpty ? "Add concerts to see your venues here" : "Try a different search term")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
    }
}

#Preview {
    NavigationStack {
        VenueListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
