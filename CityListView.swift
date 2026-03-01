//
//  CityListView.swift
//  Concert App
//
//  Created by Michael Tempestini on 3/1/26.
//

import SwiftUI
import CoreData

struct CityWithCount: Identifiable {
    let id = UUID()
    let city: String
    let state: String
    let showCount: Int
}

struct CityListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Concert.date, ascending: false)],
        animation: .default)
    private var concerts: FetchedResults<Concert>
    
    @State private var searchText = ""
    
    // Build city list with counts, sorted by count (highest to lowest)
    var allCities: [CityWithCount] {
        var cityCounts: [String: Int] = [:]
        
        for concert in concerts {
            if !concert.wrappedCity.isEmpty {
                let key = "\(concert.wrappedCity)|\(concert.wrappedState)"
                cityCounts[key, default: 0] += 1
            }
        }
        
        return cityCounts.map { key, count in
            let parts = key.split(separator: "|")
            return CityWithCount(
                city: String(parts[0]),
                state: String(parts[1]),
                showCount: count
            )
        }
        .sorted { $0.showCount > $1.showCount }
    }
    
    var filteredCities: [CityWithCount] {
        if searchText.isEmpty {
            return allCities
        }
        return allCities.filter {
            $0.city.localizedCaseInsensitiveContains(searchText) ||
            $0.state.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredCities) { city in
                NavigationLink(destination: CityDetailView(city: city.city, state: city.state, concerts: Array(concerts))) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(city.city), \(city.state)")
                            .font(.headline)
                        Text("\(city.showCount) show\(city.showCount == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Cities")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search cities")
        .overlay {
            if filteredCities.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: searchText.isEmpty ? "map.slash" : "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    Text(searchText.isEmpty ? "No Cities" : "No Results")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(searchText.isEmpty ? "Add concerts to see your cities here" : "Try a different search term")
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
        CityListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
