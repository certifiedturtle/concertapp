//
//  VenueDetailView.swift
//  Concert App
//
//  Created by Michael Tempestini on 3/1/26.
//

import SwiftUI
import CoreData

struct VenueDetailView: View {
    let venueName: String
    let venueCity: String
    let venueState: String
    let concerts: [Concert]
    
    // All concerts at this venue
    var venueConcerts: [Concert] {
        concerts.filter { concert in
            !concert.isFestival &&
            concert.wrappedVenueName == venueName &&
            concert.wrappedCity == venueCity &&
            concert.wrappedState == venueState
        }
        .sorted { $0.wrappedDate > $1.wrappedDate }
    }
    
    // Unique artists seen at this venue
    var uniqueArtists: Int {
        var artistNames = Set<String>()
        for concert in venueConcerts {
            for artist in concert.artistsArray {
                let name = artist.wrappedName.trimmingCharacters(in: .whitespaces)
                if !name.isEmpty {
                    artistNames.insert(name)
                }
            }
        }
        return artistNames.count
    }
    
    var body: some View {
        List {
            // Summary header
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text(venueName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if !venueCity.isEmpty {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundStyle(.secondary)
                            Text("\(venueCity), \(venueState)")
                                .foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                    }
                }
                .padding(.vertical, 8)
                
                HStack(spacing: 20) {
                    VStack {
                        Text("\(venueConcerts.count)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Total Shows")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Divider()
                    VStack {
                        Text("\(uniqueArtists)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Artists Seen")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            
            // Concert list
            Section("Shows") {
                ForEach(venueConcerts) { concert in
                    NavigationLink(destination: ConcertDetailView(concert: concert)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(concert.primaryArtistName)
                                .font(.headline)
                            
                            Text(concert.displayDate)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            if concert.artistsArray.count > 1 {
                                Text("\(concert.artistsArray.count) artists")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle(venueName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        VenueDetailView(
            venueName: "Madison Square Garden",
            venueCity: "New York",
            venueState: "NY",
            concerts: []
        )
    }
}
