//
//  FestivalHistoryView.swift
//  Concert App
//
//  Created by Michael Tempestini on 3/1/26.
//

import SwiftUI
import CoreData

struct FestivalHistoryView: View {
    let festivalGroup: GroupedFestival
    
    var body: some View {
        List {
            // Summary header
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text(festivalGroup.festivalName)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.vertical, 8)
                
                HStack(spacing: 20) {
                    VStack {
                        Text("\(festivalGroup.attendanceCount)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Times Attended")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Divider()
                    VStack {
                        Text("\(festivalGroup.totalUniqueArtists)")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Total Artists")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            
            // Years list
            Section("Years") {
                ForEach(festivalGroup.concerts) { concert in
                    NavigationLink(destination: ConcertDetailView(concert: concert)) {
                        VStack(alignment: .leading, spacing: 4) {
                            // Year as primary text
                            let calendar = Calendar.current
                            let year = calendar.component(.year, from: concert.wrappedDate)
                            Text(String(year))
                                .font(.headline)
                            
                            // Artist count as secondary text
                            Text("\(concert.artistsArray.count) artist\(concert.artistsArray.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            // Show date and location
                            HStack {
                                Text(concert.displayDate)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                if !concert.wrappedCity.isEmpty {
                                    Text("•")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("\(concert.wrappedCity), \(concert.wrappedState)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("\(festivalGroup.festivalName) History")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    let previewGroup = GroupedFestival(
        festivalName: "Riot Fest",
        concerts: [],
        attendanceCount: 4,
        totalUniqueArtists: 120
    )
    
    NavigationStack {
        FestivalHistoryView(festivalGroup: previewGroup)
    }
}
