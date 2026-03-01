//
//  ConcertsListView.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
//

import SwiftUI
import CoreData

enum ConcertSortOption: String, CaseIterable {
    case allConcerts = "All Concerts"
    case festivalsOnly = "Festivals Only"
    case concertsOnly = "Concerts Only"
    case artists = "Artists"
}

// Artist data structure for display
struct ArtistWithCount: Identifiable {
    let id = UUID()
    let name: String
    let showCount: Int
}

struct ConcertsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Concert.date, ascending: false)],
        animation: .default)
    private var concerts: FetchedResults<Concert>
    
    @State private var showingAddConcert = false
    @State private var searchText = ""
    @State private var selectedSortOption: ConcertSortOption = .allConcerts
    
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
    
    // Filtered artists based on search
    var filteredArtists: [ArtistWithCount] {
        if searchText.isEmpty {
            return allArtists
        }
        return allArtists.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var filteredConcerts: [Concert] {
        var result = Array(concerts)
        
        // Apply sort/filter option
        switch selectedSortOption {
        case .allConcerts:
            break // Show all
        case .festivalsOnly:
            result = result.filter { $0.isFestival }
        case .concertsOnly:
            result = result.filter { !$0.isFestival }
        case .artists:
            return [] // Artists mode doesn't show concerts
        }
        
        // Apply search filter for concerts
        if !searchText.isEmpty {
            result = result.filter { concert in
                concert.primaryArtistName.localizedCaseInsensitiveContains(searchText) ||
                concert.wrappedVenueName.localizedCaseInsensitiveContains(searchText) ||
                concert.wrappedFestivalName.localizedCaseInsensitiveContains(searchText) ||
                concert.wrappedCity.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Show artists or concerts based on selected filter
                if selectedSortOption == .artists {
                    // Artist mode
                    ForEach(filteredArtists) { artist in
                        NavigationLink(destination: ArtistDetailView(artistName: artist.name, concerts: Array(concerts))) {
                            ArtistRowView(artistName: artist.name, showCount: artist.showCount)
                        }
                    }
                } else {
                    // Concert mode
                    ForEach(filteredConcerts) { concert in
                        NavigationLink(destination: ConcertDetailView(concert: concert)) {
                            ConcertRowView(concert: concert)
                        }
                    }
                    .onDelete(perform: deleteConcerts)
                }
            }
            .navigationTitle("My Concerts")
            .searchable(text: $searchText, prompt: selectedSortOption == .artists ? "Search artists" : "Search concerts")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        ForEach(ConcertSortOption.allCases, id: \.self) { option in
                            Button {
                                // Clear search when switching away from artists
                                if selectedSortOption == .artists && option != .artists {
                                    searchText = ""
                                }
                                selectedSortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if selectedSortOption == option {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        if selectedSortOption == .allConcerts {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        } else {
                            Text(selectedSortOption.rawValue)
                                .font(.subheadline)
                        }
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddConcert = true
                    } label: {
                        Label("Add Concert", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddConcert) {
                AddEditConcertView()
                    .environment(\.managedObjectContext, viewContext)
            }
            .overlay {
                if selectedSortOption == .artists {
                    // Empty states for artists
                    if allArtists.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            Text("No Artists Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Add concerts to see your artists here")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    } else if filteredArtists.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            Text("No Results")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Try a different search term")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    }
                } else {
                    // Empty states for concerts
                    if concerts.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            
                            Text("No Concerts Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Tap + to add your first concert")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    } else if filteredConcerts.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            
                            Text("No Results")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Try adjusting your filters or search")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    private func deleteConcerts(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredConcerts[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting: \(nsError.localizedDescription)")
            }
        }
    }
}

// MARK: - Artist Row View

struct ArtistRowView: View {
    let artistName: String
    let showCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(artistName)
                .font(.headline)
            Text("\(showCount) show\(showCount == 1 ? "" : "s")")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Concert Row View

struct ConcertRowView: View {
    @ObservedObject var concert: Concert
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // For festivals, show festival name + year; for standard concerts, show primary artist
                Text(concert.isFestival ? concert.festivalDisplayName : concert.primaryArtistName)
                    .font(.headline)
                
                if concert.isFestival {
                    Image(systemName: "tent.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
                
                Spacer()
            }
            
            Text(concert.displayDate)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // For festivals, show city/state; for standard concerts, show venue + city/state
            if concert.isFestival {
                if !concert.wrappedCity.isEmpty {
                    Text("\(concert.wrappedCity), \(concert.wrappedState)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                HStack {
                    Text(concert.wrappedVenueName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if !concert.wrappedCity.isEmpty {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text("\(concert.wrappedCity), \(concert.wrappedState)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            if concert.artistsArray.count > 1 {
                Text("\(concert.artistsArray.count) artists")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ConcertsListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
