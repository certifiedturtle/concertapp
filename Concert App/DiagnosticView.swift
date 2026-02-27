//
//  DiagnosticView.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
//

import SwiftUI
import CoreData

/// Use this view to test if Core Data is set up correctly
struct DiagnosticView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var testResult = "Testing..."
    @State private var testColor: Color = .blue
    @State private var dataStats: (concerts: Int, artists: Int, photos: Int) = (0, 0, 0)
    @State private var showingClearAlert = false
    @State private var showingClearPhotosAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Core Data Status") {
                    HStack {
                        Image(systemName: testColor == .green ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .font(.title2)
                            .foregroundStyle(testColor)
                        
                        VStack(alignment: .leading) {
                            Text("Status")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(testColor == .green ? "Working" : "Error")
                                .font(.headline)
                        }
                    }
                    
                    Button("Run Diagnostic Test") {
                        runDiagnostic()
                    }
                }
                
                Section("Database Statistics") {
                    HStack {
                        Label("Concerts", systemImage: "music.note.list")
                        Spacer()
                        Text("\(dataStats.concerts)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Label("Artists", systemImage: "person.2")
                        Spacer()
                        Text("\(dataStats.artists)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Label("Photos", systemImage: "photo.stack")
                        Spacer()
                        Text("\(dataStats.photos)")
                            .fontWeight(.semibold)
                    }
                    
                    Button("Refresh Stats") {
                        refreshStats()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Section("Testing Tools") {
                    Button(role: .destructive) {
                        showingClearPhotosAlert = true
                    } label: {
                        Label("Clear All Photos", systemImage: "photo.on.rectangle.angled")
                    }
                    
                    Button(role: .destructive) {
                        showingClearAlert = true
                    } label: {
                        Label("Clear All Data", systemImage: "trash")
                    }
                }
                
                Section("Test Details") {
                    Text(testResult)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Diagnostics")
            .onAppear {
                runDiagnostic()
                refreshStats()
            }
            .alert("Clear All Photos?", isPresented: $showingClearPhotosAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear Photos", role: .destructive) {
                    clearPhotos()
                }
            } message: {
                Text("This will remove all photo references from all concerts. The actual photos in your library will not be deleted. This action cannot be undone.")
            }
            .alert("Clear All Data?", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear Everything", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will delete all concerts, artists, and photos from the app. This action cannot be undone.")
            }
        }
    }
    
    private func refreshStats() {
        dataStats = PersistenceController.shared.getDataStats()
    }
    
    private func clearPhotos() {
        do {
            try PersistenceController.shared.clearAllPhotos()
            refreshStats()
            testResult = "✅ Successfully cleared all photos"
            testColor = .green
        } catch {
            testResult = "❌ Error clearing photos: \(error.localizedDescription)"
            testColor = .red
        }
    }
    
    private func clearAllData() {
        do {
            try PersistenceController.shared.clearAllData()
            refreshStats()
            testResult = "✅ Successfully cleared all data"
            testColor = .green
        } catch {
            testResult = "❌ Error clearing data: \(error.localizedDescription)"
            testColor = .red
        }
    }
    
    private func runDiagnostic() {
        testResult = "Testing Core Data setup..."
        testColor = .blue
        
        // Test 1: Check if context exists
        guard viewContext.persistentStoreCoordinator != nil else {
            testResult = "❌ Error: No persistent store coordinator found"
            testColor = .red
            return
        }
        
        // Test 2: Try to create a Concert entity
        do {
            let concert = Concert(context: viewContext)
            concert.id = UUID()
            concert.date = Date()
            concert.venueName = "Test Venue"
            concert.city = "Test City"
            concert.state = "NY"
            concert.concertType = "standard"
            
            // Test 3: Try to create an Artist entity
            let artist = Artist(context: viewContext)
            artist.id = UUID()
            artist.name = "Test Artist"
            artist.isHeadliner = true
            artist.concert = concert
            
            // Test 4: Try to save
            try viewContext.save()
            
            // Test 5: Try to fetch
            let fetchRequest: NSFetchRequest<Concert> = Concert.fetchRequest()
            let results = try viewContext.fetch(fetchRequest)
            
            // Clean up test data
            viewContext.delete(concert)
            try viewContext.save()
            
            testResult = """
            ✅ All Tests Passed!
            
            Core Data is working correctly.
            Created \(results.count) test concert(s).
            
            Your app should work fine!
            """
            testColor = .green
            
        } catch let error as NSError {
            testResult = """
            ❌ Core Data Error:
            
            \(error.localizedDescription)
            
            Domain: \(error.domain)
            Code: \(error.code)
            
            Check DEBUG_GUIDE.md for solutions.
            """
            testColor = .red
        }
    }
}

#Preview("With Context") {
    DiagnosticView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

#Preview("Without Context - Will Fail") {
    DiagnosticView()
        .environment(\.managedObjectContext, NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
}
