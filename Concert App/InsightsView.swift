//
//  InsightsView.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
//

import SwiftUI
import CoreData

struct InsightsView: View {
    @StateObject private var viewModel = InsightsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Core Stats
                    VStack(spacing: 16) {
                        StatCard(
                            title: "Total Concerts",
                            value: "\(viewModel.totalConcerts)",
                            icon: "music.note.list",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Total Festivals",
                            value: "\(viewModel.totalFestivals)",
                            icon: "tent.fill",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Unique Artists",
                            value: "\(viewModel.totalUniqueArtists)",
                            icon: "person.2.fill",
                            color: .purple
                        )
                        
                        StatCard(
                            title: "Unique Venues",
                            value: "\(viewModel.totalUniqueVenues)",
                            icon: "building.2.fill",
                            color: .brown
                        )
                        
                        StatCard(
                            title: "Unique Cities",
                            value: "\(viewModel.totalUniqueCities)",
                            icon: "map.fill",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Concerts This Year",
                            value: "\(viewModel.concertsThisYear)",
                            icon: "calendar",
                            color: .red
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Insights")
            .onAppear {
                viewModel.calculateInsights()
            }
            .refreshable {
                viewModel.calculateInsights()
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    InsightsView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
