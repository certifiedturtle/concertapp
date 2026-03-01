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
                            color: .blue,
                            destination: nil // Not tappable
                        )
                        
                        StatCard(
                            title: "Total Festivals",
                            value: "\(viewModel.totalFestivals)",
                            icon: "tent.fill",
                            color: .orange,
                            destination: AnyView(FestivalListView())
                        )
                        
                        StatCard(
                            title: "Unique Artists",
                            value: "\(viewModel.totalUniqueArtists)",
                            icon: "person.2.fill",
                            color: .purple,
                            destination: AnyView(InsightsArtistListView())
                        )
                        
                        StatCard(
                            title: "Unique Venues",
                            value: "\(viewModel.totalUniqueVenues)",
                            icon: "building.2.fill",
                            color: .brown,
                            destination: AnyView(VenueListView())
                        )
                        
                        StatCard(
                            title: "Unique Cities",
                            value: "\(viewModel.totalUniqueCities)",
                            icon: "map.fill",
                            color: .green,
                            destination: AnyView(CityListView())
                        )
                        
                        StatCard(
                            title: "Concerts This Year",
                            value: "\(viewModel.concertsThisYear)",
                            icon: "calendar",
                            color: .red,
                            destination: AnyView(ThisYearConcertsView())
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
    let destination: AnyView?
    
    private var isZero: Bool {
        value == "0"
    }
    
    private var isTappable: Bool {
        destination != nil && !isZero
    }
    
    var body: some View {
        Group {
            if isTappable, let destination = destination {
                NavigationLink(destination: destination) {
                    cardContent
                }
                .buttonStyle(.plain)
            } else {
                cardContent
                    .opacity(isZero ? 0.5 : 1.0)
            }
        }
    }
    
    private var cardContent: some View {
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
            
            if isTappable {
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
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
