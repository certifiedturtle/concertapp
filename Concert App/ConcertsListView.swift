//
//  ConcertsListView.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
//

import SwiftUI
import CoreData

struct ConcertsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Concert.date, ascending: false)],
        animation: .default)
    private var concerts: FetchedResults<Concert>
    
    @State private var showingAddConcert = false
    @State private var searchText = ""
    
    var filteredConcerts: [Concert] {
        if searchText.isEmpty {
            return Array(concerts)
        } else {
            return concerts.filter { concert in
                concert.primaryArtistName.localizedCaseInsensitiveContains(searchText) ||
                concert.wrappedVenueName.localizedCaseInsensitiveContains(searchText) ||
                concert.wrappedCity.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredConcerts) { concert in
                    NavigationLink(destination: ConcertDetailView(concert: concert)) {
                        ConcertRowView(concert: concert)
                    }
                }
                .onDelete(perform: deleteConcerts)
            }
            .navigationTitle("My Concerts")
            .searchable(text: $searchText, prompt: "Search concerts")
            .toolbar {
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

struct ConcertRowView: View {
    let concert: Concert
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(concert.primaryArtistName)
                    .font(.headline)
                
                if concert.isFestival {
                    Image(systemName: "star.circle.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
                
                Spacer()
            }
            
            Text(concert.displayDate)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
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
