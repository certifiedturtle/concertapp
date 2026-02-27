//
//  SettingsView.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultSortOrder") private var defaultSortOrder = "dateDescending"
    @AppStorage("showArtistCount") private var showArtistCount = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Toggle("Show Artist Count on Rows", isOn: $showArtistCount)
                }
                
                Section("Default Behaviors") {
                    Picker("Default Sort Order", selection: $defaultSortOrder) {
                        Text("Newest First").tag("dateDescending")
                        Text("Oldest First").tag("dateAscending")
                        Text("Artist Name").tag("artistName")
                        Text("Venue Name").tag("venueName")
                    }
                }
                
                Section("Data") {
                    Button {
                        // TODO: Implement export
                    } label: {
                        Label("Export Concert Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        // TODO: Implement backup
                    } label: {
                        Label("Backup to Files", systemImage: "folder")
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://example.com")!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }
                    
                    Link(destination: URL(string: "https://example.com")!) {
                        HStack {
                            Text("Support")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        // TODO: Add confirmation dialog
                    } label: {
                        Label("Delete All Data", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
