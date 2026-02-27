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
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Venue Name", text: $venueName)
                    
                    TextField("City", text: $city)
                    
                    TextField("State", text: $state)
                        .textInputAutocapitalization(.characters)
                }
                
                Section("Additional Info") {
                    TextField("Setlist URL", text: $setlistURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                    
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
    
    private func loadConcertData() {
        guard let concert = concert else { return }
        
        date = concert.wrappedDate
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
            
            if let concert = concert {
                try viewModel.updateConcert(
                    concert,
                    date: date,
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
                    date: date,
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
