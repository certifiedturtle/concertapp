//
//  InsightsArtistListView.swift
//  Concert App
//
//  Created by Michael Tempestini on 3/1/26.
//

import SwiftUI
import CoreData

struct InsightsArtistListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Concert.date, ascending: false)],
        animation: .default)
    private var concerts: FetchedResults<Concert>
    
    @State private var searchText = ""
    
    // Build artist list with counts, sorted by count (highest to lowest)
    var allArtists: [ArtistWithCount] {
        var artistCounts: [String: Int] = [:]
        
        for concert in concerts {
            for artist in concert.artistsArray {
                let name = artist.wrappedName.trimmingCharacters(in: .whitespaces)
                if !name.isEmpty {
                    artistCounts[name, default: 0] += 1
                }
            }
        }
        
        return artistCounts.map { ArtistWithCount(name: $0.key, showCount: $0.value) }
            .sorted { $0.showCount > $1.showCount }
    }
    
    var filteredArtists: [ArtistWithCount] {
        if searchText.isEmpty {
            return allArtists
        }
        return allArtists.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        List {
            ForEach(filteredArtists) { artist in
                NavigationLink(destination: ArtistDetailView(artistName: artist.name, concerts: Array(concerts))) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(artist.name)
                            .font(.headline)
                        Text("\(artist.showCount) show\(artist.showCount == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Artists")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search artists")
        .overlay {
            if filteredArtists.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: searchText.isEmpty ? "person.2.slash" : "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    Text(searchText.isEmpty ? "No Artists" : "No Results")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(searchText.isEmpty ? "Add concerts to see your artists here" : "Try a different search term")
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
        InsightsArtistListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
