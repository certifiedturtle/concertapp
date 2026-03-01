//
//  ArtistConcertsView.swift
//  Concert App
//
//  Created by Michael Tempestini on 3/1/26.
//

import SwiftUI
import CoreData

struct ArtistConcertsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let artistName: String
    
    @FetchRequest
    private var concerts: FetchedResults<Concert>
    
    init(artistName: String) {
        self.artistName = artistName
        
        // Fetch all concerts, we'll filter in Swift
        _concerts = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Concert.date, ascending: false)],
            animation: .default
        )
    }
    
    // Filter concerts that include this artist
    var artistConcerts: [Concert] {
        concerts.filter { concert in
            concert.artistsArray.contains { 
                $0.wrappedName.trimmingCharacters(in: .whitespacesAndNewlines) == artistName 
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(artistConcerts) { concert in
                NavigationLink(destination: ConcertDetailView(concert: concert)) {
                    ArtistConcertRowView(concert: concert, artistName: artistName)
                }
            }
        }
        .navigationTitle(artistName)
        .navigationBarTitleDisplayMode(.large)
        .overlay {
            if artistConcerts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "music.note")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    Text("No Concerts Found")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("You haven't seen \(artistName) yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
    }
}

struct ArtistConcertRowView: View {
    @ObservedObject var concert: Concert
    let artistName: String
    
    // Determine the artist's role at this concert
    var artistRole: String {
        guard let artist = concert.artistsArray.first(where: { 
            $0.wrappedName.trimmingCharacters(in: .whitespacesAndNewlines) == artistName 
        }) else {
            return "Performed"
        }
        
        if concert.isFestival {
            return "Festival"
        } else if artist.isHeadliner {
            return "Headliner"
        } else {
            return "Opener"
        }
    }
    
    var roleColor: Color {
        switch artistRole {
        case "Headliner":
            return .blue
        case "Opener":
            return .green
        case "Festival":
            return .orange
        default:
            return .secondary
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                // For festivals, show festival name + year; for standard concerts, show venue
                Text(concert.isFestival ? concert.festivalDisplayName : concert.wrappedVenueName)
                    .font(.headline)
                
                Spacer()
                
                Text(artistRole)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(roleColor.opacity(0.2))
                    .foregroundStyle(roleColor)
                    .clipShape(Capsule())
            }
            
            HStack {
                Text(concert.displayDate)
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
            
            // Show other artists if it's a multi-artist show
            if concert.artistsArray.count > 1 {
                let otherArtists = concert.artistsArray.filter { 
                    $0.wrappedName.trimmingCharacters(in: .whitespacesAndNewlines) != artistName 
                }
                if !otherArtists.isEmpty {
                    Text("with \(otherArtists.map { $0.wrappedName }.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ArtistConcertsView(artistName: "Taylor Swift")
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
