//
//  AddEditConcertView.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
//

import SwiftUI
import CoreData

enum DateEntryMode {
    case exactDate
    case monthYear
    case yearOnly
}

struct AddEditConcertView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: ConcertViewModel
    
    let concert: Concert?
    
    @State private var date = Date()
    @State private var dateEntryMode: DateEntryMode = .exactDate
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var venueName = ""
    @State private var festivalName = ""
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
                            
                            // Only show headliner toggle for standard concerts with multiple artists
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
                        // For festivals, all artists default to non-headliner
                        let isHeadliner = concertType == "standard" ? false : false
                        artists.append(("", isHeadliner))
                    } label: {
                        Label("Add Artist", systemImage: "plus.circle.fill")
                    }
                }
                
                Section("Details") {
                    // Progressive disclosure date entry
                    Group {
                        switch dateEntryMode {
                        case .exactDate:
                            exactDatePicker
                        case .monthYear:
                            monthYearPickers
                        case .yearOnly:
                            yearOnlyPicker
                        }
                    }
                    .animation(.easeInOut, value: dateEntryMode)
                    
                    // Show festival name for festivals, venue name for standard concerts
                    if concertType == "festival" {
                        TextField("Festival Name", text: $festivalName)
                            .autocorrectionDisabled()
                    } else {
                        TextField("Venue Name", text: $venueName)
                    }
                    
                    TextField("City", text: $city)
                    
                    TextField("State", text: $state)
                        .textInputAutocapitalization(.characters)
                }
                
                Section("Additional Info") {
                    TextField("Setlist URL", text: $setlistURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                    
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
    
    // MARK: - Date Pickers
    
    @ViewBuilder
    private var exactDatePicker: some View {
        DatePicker("Date", selection: $date, displayedComponents: .date)
        Button {
            // Extract month/year from current date before switching
            let calendar = Calendar.current
            selectedMonth = calendar.component(.month, from: date)
            selectedYear = calendar.component(.year, from: date)
            withAnimation(.easeInOut) {
                dateEntryMode = .monthYear
            }
        } label: {
            HStack {
                Image(systemName: "questionmark.circle")
                    .font(.caption)
                Text("Not sure of the exact date?")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.borderless)
    }
    
    @ViewBuilder
    private var monthYearPickers: some View {
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
        Button {
            withAnimation(.easeInOut) {
                dateEntryMode = .yearOnly
            }
        } label: {
            HStack {
                Image(systemName: "questionmark.circle")
                    .font(.caption)
                Text("Only know the year?")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.borderless)
        
        Button {
            withAnimation(.easeInOut) {
                dateEntryMode = .exactDate
            }
        } label: {
            HStack {
                Image(systemName: "arrow.left")
                    .font(.caption)
                Text("I know the exact date")
                    .font(.caption)
            }
            .foregroundStyle(.blue)
        }
        .buttonStyle(.borderless)
    }
    
    @ViewBuilder
    private var yearOnlyPicker: some View {
        Picker("Year", selection: $selectedYear) {
            ForEach((1960...2030).reversed(), id: \.self) { year in
                Text(String(year)).tag(year)
            }
        }
        .pickerStyle(.wheel)
        
        Button {
            withAnimation(.easeInOut) {
                dateEntryMode = .monthYear
            }
        } label: {
            HStack {
                Image(systemName: "arrow.left")
                    .font(.caption)
                Text("I know the month too")
                    .font(.caption)
            }
            .foregroundStyle(.blue)
        }
        .buttonStyle(.borderless)
    }
    
    // MARK: - Helpers
    
    private var isValid: Bool {
        let hasValidName = concertType == "festival" ? !festivalName.isEmpty : !venueName.isEmpty
        let hasAtLeastOneArtist = artists.contains(where: { !$0.name.isEmpty })
        return hasValidName && hasAtLeastOneArtist
    }
    
    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        return formatter.monthSymbols[month - 1]
    }
    
    private func loadConcertData() {
        guard let concert = concert else { return }
        
        date = concert.wrappedDate
        
        // Set UI mode based on stored granularity
        switch concert.wrappedDateGranularity {
        case "full":
            dateEntryMode = .exactDate
        case "month":
            dateEntryMode = .monthYear
        case "year":
            dateEntryMode = .yearOnly
        default:
            dateEntryMode = .exactDate
        }
        
        // Extract year and month from date
        let calendar = Calendar.current
        selectedYear = calendar.component(.year, from: concert.wrappedDate)
        selectedMonth = calendar.component(.month, from: concert.wrappedDate)
        
        venueName = concert.wrappedVenueName
        festivalName = concert.wrappedFestivalName
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
            
            let finalDate: Date
            let finalGranularity: String
            let calendar = Calendar.current
            
            switch dateEntryMode {
            case .exactDate:
                finalDate = date
                finalGranularity = "full"
            case .monthYear:
                var components = DateComponents()
                components.year = selectedYear
                components.month = selectedMonth
                components.day = 1
                finalDate = calendar.date(from: components) ?? date
                finalGranularity = "month"
            case .yearOnly:
                var components = DateComponents()
                components.year = selectedYear
                components.month = 1
                components.day = 1
                finalDate = calendar.date(from: components) ?? date
                finalGranularity = "year"
            }
            
            if let concert = concert {
                try viewModel.updateConcert(
                    concert,
                    date: finalDate,
                    dateGranularity: finalGranularity,
                    venueName: venueName,
                    festivalName: festivalName,
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
                    dateGranularity: finalGranularity,
                    venueName: venueName,
                    festivalName: festivalName,
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
        let primaryArtist: String
        if let headliner = artists.first(where: { $0.isHeadliner && !$0.name.isEmpty }) {
            primaryArtist = headliner.name
        } else if let firstArtist = artists.first(where: { !$0.name.isEmpty }) {
            primaryArtist = firstArtist.name
        } else {
            primaryArtist = "Unknown Artist"
        }
        
        let venue = venueName.isEmpty ? "Unknown Venue" : venueName
        
        let dateString: String
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        
        switch dateEntryMode {
        case .exactDate:
            dateFormatter.dateStyle = .long
            dateString = dateFormatter.string(from: date)
        case .monthYear:
            dateFormatter.dateFormat = "MMMM yyyy"
            var components = DateComponents()
            components.year = selectedYear
            components.month = selectedMonth
            components.day = 1
            let tempDate = calendar.date(from: components) ?? date
            dateString = dateFormatter.string(from: tempDate)
        case .yearOnly:
            dateString = String(selectedYear)
        }
        
        var queryComponents = ["setlistfm", primaryArtist, venue]
        
        if !city.isEmpty && !state.isEmpty {
            queryComponents.append("\(city), \(state)")
        } else if !city.isEmpty {
            queryComponents.append(city)
        }
        
        queryComponents.append(dateString)
        
        let query = queryComponents.joined(separator: " ")
        
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
