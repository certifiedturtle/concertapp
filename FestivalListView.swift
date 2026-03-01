//
//  FestivalListView.swift
//  Concert App
//
//  Created by Michael Tempestini on 3/1/26.
//

import SwiftUI
import CoreData

struct FestivalListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Concert.date, ascending: false)],
        predicate: NSPredicate(format: "concertType == %@", "festival"),
        animation: .default)
    private var festivals: FetchedResults<Concert>
    
    @State private var searchText = ""
    
    var filteredFestivals: [Concert] {
        if searchText.isEmpty {
            return Array(festivals)
        }
        return festivals.filter { festival in
            festival.wrappedFestivalName.localizedCaseInsensitiveContains(searchText) ||
            festival.wrappedCity.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredFestivals) { festival in
                NavigationLink(destination: ConcertDetailView(concert: festival)) {
                    FestivalRowView(festival: festival)
                }
            }
        }
        .navigationTitle("Festivals")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search festivals")
        .overlay {
            if filteredFestivals.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: searchText.isEmpty ? "tent.fill" : "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    Text(searchText.isEmpty ? "No Festivals" : "No Results")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(searchText.isEmpty ? "Add festival concerts to see them here" : "Try a different search term")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
    }
}

struct FestivalRowView: View {
    @ObservedObject var festival: Concert
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(festival.festivalDisplayName)
                    .font(.headline)
                
                Spacer()
            }
            
            Text(festival.displayDate)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if !festival.wrappedCity.isEmpty {
                Text("\(festival.wrappedCity), \(festival.wrappedState)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            if festival.artistsArray.count > 0 {
                Text("\(festival.artistsArray.count) artist\(festival.artistsArray.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        FestivalListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
