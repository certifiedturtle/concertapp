//
//  CityDetailView.swift
//  Concert App
//
//  Created by Michael Tempestini on 3/1/26.
//

import SwiftUI
import CoreData

struct CityDetailView: View {
    let city: String
    let state: String
    let concerts: [Concert]
    
    // All concerts in this city
    var cityConcerts: [Concert] {
        concerts.filter { concert in
            concert.wrappedCity == city && concert.wrappedState == state
        }
        .sorted { $0.wrappedDate > $1.wrappedDate }
    }
    
    // Unique venues visited in this city
    var uniqueVenues: Int {
        var venueNames = Set<String>()
        for concert in cityConcerts {
            if !concert.isFestival && !concert.wrappedVenueName.isEmpty && concert.wrappedVenueName != "Unknown Venue" {
                venueNames.insert(concert.wrappedVenueName)
            }
        }
        return venueNames.count
    }
    
    // Festival count in this city
    var festivalCount: Int {
        cityConcerts.filter { $0.isFestival }.count
    }
    
    var body: some View {
        List {
            // Summary header
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(city), \(state)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.vertical, 8)
                
                HStack(spacing: 20) {
                    VStack {
                        Text("\(cityConcerts.count)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Total Shows")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Divider()
                    VStack {
                        Text("\(uniqueVenues)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Venues")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Divider()
                    VStack {
                        Text("\(festivalCount)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Festivals")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            
            // Concert list
            Section("Shows") {
                ForEach(cityConcerts) { concert in
                    NavigationLink(destination: ConcertDetailView(concert: concert)) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(concert.isFestival ? concert.festivalDisplayName : concert.primaryArtistName)
                                    .font(.headline)
                                
                                if concert.isFestival {
                                    Image(systemName: "tent.fill")
                                        .foregroundStyle(.orange)
                                        .font(.caption)
                                }
                            }
                            
                            Text(concert.displayDate)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            if !concert.isFestival {
                                Text(concert.wrappedVenueName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
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
            }
        }
        .navigationTitle(city)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        CityDetailView(
            city: "New York",
            state: "NY",
            concerts: []
        )
    }
}
