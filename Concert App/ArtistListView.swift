//
//  ArtistListView.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
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

    // Build a deduplicated, alphabetically sorted list of all artist names
    var allArtists: [String] {
        var names = Set<String>()
        for concert in concerts {
            for artist in concert.artistsArray {
                let name = artist.wrappedName.trimmingCharacters(in: .whitespaces)
                if !name.isEmpty {
                    names.insert(name)
                }
            }
        }
        return names.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    var filteredArtists: [String] {
        if searchText.isEmpty {
            return allArtists
        }
        return allArtists.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    // Count how many times each artist appears across all concerts
    func concertCount(for artistName: String) -> Int {
        concerts.filter { concert in
            concert.artistsArray.contains { $0.wrappedName.localizedCaseInsensitiveCompare(artistName) == .orderedSame }
        }.count
    }

    var body: some View {
        List {
            ForEach(filteredArtists, id: \.self) { artistName in
                NavigationLink(destination: ArtistDetailView(artistName: artistName, concerts: Array(concerts))) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(artistName)
                                .font(.headline)
                            Text("\(concertCount(for: artistName)) show\(concertCount(for: artistName) == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Artists")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search artists")
        .overlay {
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
            }
        }
    }
}

// MARK: - Artist Detail View

struct ArtistDetailView: View {
    let artistName: String
    let concerts: [Concert]

    // All concerts this artist appeared in, newest first
    var artistConcerts: [Concert] {
        concerts.filter { concert in
            concert.artistsArray.contains { $0.wrappedName.localizedCaseInsensitiveCompare(artistName) == .orderedSame }
        }
    }

    var body: some View {
        List {
            // Summary header
            Section {
                HStack(spacing: 20) {
                    VStack {
                        Text("\(artistConcerts.count)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Total Shows")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Divider()
                    VStack {
                        Text("\(headlinerCount)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Headliner")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Divider()
                    VStack {
                        Text("\(openerCount)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Opener")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Divider()
                    VStack {
                        Text("\(festivalCount)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Festival")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            // Concert list
            Section("Shows") {
                ForEach(artistConcerts) { concert in
                    NavigationLink(destination: ConcertDetailView(concert: concert)) {
                        ArtistConcertRowView(concert: concert, artistName: artistName)
                    }
                }
            }
        }
        .navigationTitle(artistName)
        .navigationBarTitleDisplayMode(.large)
    }

    private var headlinerCount: Int {
        artistConcerts.filter { concert in
            concert.artistsArray.first(where: {
                $0.wrappedName.localizedCaseInsensitiveCompare(artistName) == .orderedSame
            })?.isHeadliner == true && !concert.isFestival
        }.count
    }

    private var openerCount: Int {
        artistConcerts.filter { concert in
            let artist = concert.artistsArray.first(where: {
                $0.wrappedName.localizedCaseInsensitiveCompare(artistName) == .orderedSame
            })
            return artist?.isHeadliner == false && !concert.isFestival
        }.count
    }

    private var festivalCount: Int {
        artistConcerts.filter { $0.isFestival }.count
    }
}



#Preview {
    NavigationStack {
        ArtistListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
