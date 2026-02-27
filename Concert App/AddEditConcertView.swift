//
//  AddEditConcertView.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
//

import SwiftUI
import CoreData

struct AddEditConcertView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: ConcertViewModel
    
    let concert: Concert?
    
    @State private var date = Date()
    @State private var dateGranularity = "full" // "full", "month", "year"
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var venueName = ""
    @State private var city = ""
    @State private var state = ""
    @State private var concertDescription = ""
    @State private var setlistURL = ""
    @State private var concertType = "standard"
    @State private var friendsTags = ""
    @State private var artists: [(name: String, isHeadliner: Bool)] = [("", true)]
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let concertTypes = ["standard", "festival"]
    
    init(concert: Concert? = nil) {
        self.concert = concert
        _viewModel = StateObject(wrappedValue: ConcertViewModel())
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Concert Type") {
                    Picker("Type", selection: $concertType) {
                        Text("Standard").tag("standard")
                        Text("Festival").tag("festival")
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Artists") {
                    ForEach(artists.indices, id: \.self) { index in
                        HStack {
                            TextField("Artist Name", text: $artists[index].name)
                            
                            if concertType == "standard" && artists.count > 1 {
                                Toggle("Headliner", isOn: $artists[index].isHeadliner)
                                    .labelsHidden()
                            }
                            
                            if artists.count > 1 {
                                Button(role: .destructive) {
                                    artists.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                    
                    Button {
                        artists.append(("", false))
                    } label: {
                        Label("Add Artist", systemImage: "plus.circle.fill")
                    }
                }
                
                Section("Details") {
                    // Date Granularity Picker
                    Picker("Date Precision", selection: $dateGranularity) {
                        Text("Exact Date").tag("full")
                        Text("Month & Year").tag("month")
                        Text("Year Only").tag("year")
                    }
                    .pickerStyle(.segmented)
                    
                    // Show appropriate date input based on granularity
                    switch dateGranularity {
                    case "full":
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                    case "month":
                        HStack {
                            Picker("Month", selection: $selectedMonth) {
                                ForEach(1...12, id: \.self) { month in
                                    Text(monthName(for: month)).tag(month)
                                }
                            }
                            Picker("Year", selection: $selectedYear) {
                                ForEach((1960...2030).reversed(), id: \.self) { year in
                                    Text(String(year)).tag(year)
                                }
                            }
                        }
                    case "year":
                        Picker("Year", selection: $selectedYear) {
                            ForEach((1960...2030).reversed(), id: \.self) { year in
                                Text(String(year)).tag(year)
                            }
                        }
                        .pickerStyle(.wheel)
                    default:
                        EmptyView()
                    }
                    
                    TextField("Venue Name", text: $venueName)
                    
                    TextField("City", text: $city)
                    
                    TextField("State", text: $state)
                        .textInputAutocapitalization(.characters)
                }
                
                Section("Additional Info") {
                    TextField("Setlist URL", text: $setlistURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                    
                    // Show search button if setlist URL is empty
                    if setlistURL.isEmpty {
                        Button {
                            searchForSetlist()
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Search for Setlist")
                                Spacer()
                                Image(systemName: "safari")
                                    .font(.caption)
                            }
                        }
                    }
                    
                    TextField("Friends (comma separated)", text: $friendsTags)
                    
                    TextField("Description", text: $concertDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(concert == nil ? "Add Concert" : "Edit Concert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveConcert()
                    }
                    .disabled(!isValid)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadConcertData()
            }
        }
    }
    
    private var isValid: Bool {
        !venueName.isEmpty && artists.contains(where: { !$0.name.isEmpty })
    }
    
    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        return formatter.monthSymbols[month - 1]
    }
    
    private func loadConcertData() {
        guard let concert = concert else { return }
        
        date = concert.wrappedDate
        dateGranularity = concert.wrappedDateGranularity
        
        // Extract year and month from date
        let calendar = Calendar.current
        selectedYear = calendar.component(.year, from: concert.wrappedDate)
        selectedMonth = calendar.component(.month, from: concert.wrappedDate)
        
        venueName = concert.wrappedVenueName
        city = concert.wrappedCity
        state = concert.wrappedState
        concertDescription = concert.concertDescription ?? ""
        setlistURL = concert.setlistURL ?? ""
        concertType = concert.wrappedConcertType
        friendsTags = concert.friendsTags ?? ""
        
        let existingArtists = concert.artistsArray.map { ($0.wrappedName, $0.isHeadliner) }
        artists = existingArtists.isEmpty ? [("", true)] : existingArtists
    }
    
    private func saveConcert() {
        do {
            let filteredArtists = artists.filter { !$0.name.isEmpty }
            
            // Construct date based on granularity
            let finalDate: Date
            let calendar = Calendar.current
            
            switch dateGranularity {
            case "full":
                finalDate = date
            case "month":
                // Create date as first day of selected month/year
                var components = DateComponents()
                components.year = selectedYear
                components.month = selectedMonth
                components.day = 1
                finalDate = calendar.date(from: components) ?? date
            case "year":
                // Create date as January 1 of selected year
                var components = DateComponents()
                components.year = selectedYear
                components.month = 1
                components.day = 1
                finalDate = calendar.date(from: components) ?? date
            default:
                finalDate = date
            }
            
            if let concert = concert {
                try viewModel.updateConcert(
                    concert,
                    date: finalDate,
                    dateGranularity: dateGranularity,
                    venueName: venueName,
                    city: city,
                    state: state,
                    description: concertDescription,
                    setlistURL: setlistURL,
                    concertType: concertType,
                    friendsTags: friendsTags,
                    artists: filteredArtists
                )
            } else {
                try viewModel.createConcert(
                    date: finalDate,
                    dateGranularity: dateGranularity,
                    venueName: venueName,
                    city: city,
                    state: state,
                    description: concertDescription,
                    setlistURL: setlistURL,
                    concertType: concertType,
                    friendsTags: friendsTags,
                    artists: filteredArtists
                )
            }
            
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private func searchForSetlist() {
        // Build search query: "setlistfm [artist] [venue] [city, state] [date]"
        
        // Get primary artist (first headliner or first artist)
        let primaryArtist: String
        if let headliner = artists.first(where: { $0.isHeadliner && !$0.name.isEmpty }) {
            primaryArtist = headliner.name
        } else if let firstArtist = artists.first(where: { !$0.name.isEmpty }) {
            primaryArtist = firstArtist.name
        } else {
            primaryArtist = "Unknown Artist"
        }
        
        let venue = venueName.isEmpty ? "Unknown Venue" : venueName
        
        // Format date based on granularity
        let dateString: String
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        
        switch dateGranularity {
        case "full":
            dateFormatter.dateStyle = .long
            dateString = dateFormatter.string(from: date)
        case "month":
            dateFormatter.dateFormat = "MMMM yyyy"
            var components = DateComponents()
            components.year = selectedYear
            components.month = selectedMonth
            components.day = 1
            let tempDate = calendar.date(from: components) ?? date
            dateString = dateFormatter.string(from: tempDate)
        case "year":
            dateString = String(selectedYear)
        default:
            dateFormatter.dateStyle = .long
            dateString = dateFormatter.string(from: date)
        }
        
        // Build query components
        var queryComponents = ["setlistfm", primaryArtist, venue]
        
        // Add city and state if available
        if !city.isEmpty && !state.isEmpty {
            queryComponents.append("\(city), \(state)")
        } else if !city.isEmpty {
            queryComponents.append(city)
        }
        
        queryComponents.append(dateString)
        
        let query = queryComponents.joined(separator: " ")
        
        // URL encode and open Safari with Google search
        if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://www.google.com/search?q=\(encodedQuery)") {
            UIApplication.shared.open(url)
            print("🔍 Searching for setlist: \(query)")
        } else {
            print("❌ Could not create search URL")
        }
    }
}

#Preview("Add") {
    AddEditConcertView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

#Preview("Edit") {
    let context = PersistenceController.preview.container.viewContext
    let concert = Concert(context: context)
    concert.id = UUID()
    concert.date = Date()
    concert.venueName = "Madison Square Garden"
    concert.city = "New York"
    concert.state = "NY"
    
    return AddEditConcertView(concert: concert)
        .environment(\.managedObjectContext, context)
}
