//
//  SimplifiedApp.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
//

import SwiftUI

/// Temporary simplified view to test if app runs without Core Data
struct SimplifiedAppView: View {
    var body: some View {
        TabView {
            NavigationStack {
                VStack(spacing: 20) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                    
                    Text("Concert App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Core Data setup in progress...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                        .padding()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Setup Checklist:")
                            .font(.headline)
                        
                        ChecklistItem(text: "Create ConcertApp.xcdatamodeld file")
                        ChecklistItem(text: "Add Concert, Artist, ConcertPhoto entities")
                        ChecklistItem(text: "Set all Codegen to Manual/None")
                        ChecklistItem(text: "Configure relationships")
                        ChecklistItem(text: "Build and run!")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
                .navigationTitle("Setup")
            }
            .tabItem {
                Label("Setup", systemImage: "wrench.and.screwdriver")
            }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct ChecklistItem: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "square")
                .foregroundStyle(.secondary)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    SimplifiedAppView()
}
