//
//  ThisYearConcertsView.swift
//  Concert App
//
//  Created by Michael Tempestini on 3/1/26.
//

import SwiftUI
import CoreData

struct ThisYearConcertsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest
    private var concerts: FetchedResults<Concert>
    
    @State private var searchText = ""
    
    init() {
        let calendar = Calendar.current
        let now = Date()
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now)) ?? now
        let endOfYear = calendar.date(byAdding: DateComponents(year: 1, day: -1), to: startOfYear) ?? now
        
        _concerts = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Concert.date, ascending: false)],
            predicate: NSPredicate(format: "date >= %@ AND date <= %@", startOfYear as NSDate, endOfYear as NSDate),
            animation: .default
        )
    }
    
    var filteredConcerts: [Concert] {
        if searchText.isEmpty {
            return Array(concerts)
        }
        return concerts.filter { concert in
            concert.primaryArtistName.localizedCaseInsensitiveContains(searchText) ||
            concert.wrappedVenueName.localizedCaseInsensitiveContains(searchText) ||
            concert.wrappedFestivalName.localizedCaseInsensitiveContains(searchText) ||
            concert.wrappedCity.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredConcerts) { concert in
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
        }
        .navigationTitle("Concerts This Year")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search concerts")
        .overlay {
            if filteredConcerts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: searchText.isEmpty ? "calendar.badge.exclamationmark" : "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    Text(searchText.isEmpty ? "No Concerts This Year" : "No Results")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(searchText.isEmpty ? "Add concerts to see them here" : "Try a different search term")
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
        ThisYearConcertsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
