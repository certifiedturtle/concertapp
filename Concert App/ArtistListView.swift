//
//  ArtistListView.swift
//  Concert App
//
//  Created by Michael Tempestini on 3/1/26.
//

import SwiftUI
import CoreData

struct ArtistListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Concert.date, ascending: false)],
        animation: .default)
    private var concerts: FetchedResults<Concert>
    
    @State private var searchText = ""
    
    // Compute unique artists with concert counts
    var artistData: [(name: String, count: Int)] {
        var artistCounts: [String: Int] = [:]
        
        for concert in concerts {
            for artist in concert.artistsArray {
                let name = artist.wrappedName
                artistCounts[name, default: 0] += 1
            }
        }
        
        return artistCounts.map { (name: $0.key, count: $0.value) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    var filteredArtists: [(name: String, count: Int)] {
        if searchText.isEmpty {
            return artistData
        } else {
            return artistData.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredArtists, id: \.name) { artist in
                NavigationLink(destination: ArtistConcertsView(artistName: artist.name)) {
                    HStack {
                        Text(artist.name)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(artist.count) concert\(artist.count == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Artists")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search artists")
        .overlay {
            if filteredArtists.isEmpty && !searchText.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    Text("No Artists Found")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Try a different search term")
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
        ArtistListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
