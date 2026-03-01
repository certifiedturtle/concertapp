//
//  ConcertExportManager.swift
//  Concert App
//
//  Created by Michael Tempestini on 3/1/26.
//

import Foundation
import PDFKit
import UIKit

class ConcertExportManager {
    
    // MARK: - Data Preparation
    
    struct ExportRow {
        let date: String
        let type: String
        let festivalName: String
        let venueName: String
        let artistName: String
        let artistRole: String
        let city: String
        let state: String
        let description: String
        let friends: String
        let setlistURL: String
    }
    
    static func prepareExportData(concerts: [Concert]) -> [ExportRow] {
        var rows: [ExportRow] = []
        
        // Sort concerts newest first
        let sortedConcerts = concerts.sorted { $0.wrappedDate > $1.wrappedDate }
        
        for concert in sortedConcerts {
            let dateString = formatDate(concert)
            let type = concert.isFestival ? "Festival" : "Standard"
            let festivalName = concert.isFestival ? concert.wrappedFestivalName : ""
            let venueName = concert.isFestival ? "" : concert.wrappedVenueName
            let city = concert.wrappedCity
            let state = concert.wrappedState
            let description = concert.concertDescription ?? ""
            let friends = concert.friendsTags ?? ""
            let setlistURL = concert.setlistURL ?? ""
            
            // Create one row per artist
            let artists = concert.artistsArray
            if artists.isEmpty {
                // If no artists, create one row with concert info
                rows.append(ExportRow(
                    date: dateString,
                    type: type,
                    festivalName: festivalName,
                    venueName: venueName,
                    artistName: "",
                    artistRole: "",
                    city: city,
                    state: state,
                    description: description,
                    friends: friends,
                    setlistURL: setlistURL
                ))
            } else {
                for artist in artists {
                    let role: String
                    if concert.isFestival {
                        role = "Festival"
                    } else {
                        role = artist.isHeadliner ? "Headliner" : "Opener"
                    }
                    
                    rows.append(ExportRow(
                        date: dateString,
                        type: type,
                        festivalName: festivalName,
                        venueName: venueName,
                        artistName: artist.wrappedName,
                        artistRole: role,
                        city: city,
                        state: state,
                        description: description,
                        friends: friends,
                        setlistURL: setlistURL
                    ))
                }
            }
        }
        
        return rows
    }
    
    static func formatDate(_ concert: Concert) -> String {
        let formatter = DateFormatter()
        
        switch concert.wrappedDateGranularity {
        case "full":
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: concert.wrappedDate)
        case "month":
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: concert.wrappedDate)
        case "year":
            formatter.dateFormat = "yyyy"
            return formatter.string(from: concert.wrappedDate)
        default:
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: concert.wrappedDate)
        }
    }
    
    // MARK: - CSV Generation
    
    static func generateCSV(concerts: [Concert]) -> String {
        let rows = prepareExportData(concerts: concerts)
        
        var csv = "Date,Type,Festival Name,Venue Name,Artist Name,Artist Role,City,State,Description,Friends,Setlist URL\n"
        
        for row in rows {
            let fields = [
                escapeCSV(row.date),
                escapeCSV(row.type),
                escapeCSV(row.festivalName),
                escapeCSV(row.venueName),
                escapeCSV(row.artistName),
                escapeCSV(row.artistRole),
                escapeCSV(row.city),
                escapeCSV(row.state),
                escapeCSV(row.description),
                escapeCSV(row.friends),
                escapeCSV(row.setlistURL)
            ]
            csv += fields.joined(separator: ",") + "\n"
        }
        
        return csv
    }
    
    static func escapeCSV(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return field
    }
    
    // MARK: - PDF Generation
    
    static func generatePDF(concerts: [Concert]) -> Data? {
        let rows = prepareExportData(concerts: concerts)
        
        let pageWidth: CGFloat = 612 // 8.5 inches
        let pageHeight: CGFloat = 792 // 11 inches
        let margin: CGFloat = 36 // 0.5 inch margins
        
        let pdfMetaData = [
            kCGPDFContextCreator: "Concert App",
            kCGPDFContextAuthor: "User",
            kCGPDFContextTitle: "My Concert History"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = margin
            
            // Title
            let titleFont = UIFont.boldSystemFont(ofSize: 18)
            let title = "My Concert History: \(concerts.count) Concert\(concerts.count == 1 ? "" : "s")"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
            yPosition += titleSize.height + 20
            
            // Table headers
            let headerFont = UIFont.boldSystemFont(ofSize: 8)
            let cellFont = UIFont.systemFont(ofSize: 7)
            
            let columnWidths: [CGFloat] = [60, 40, 60, 80, 80, 45, 50, 30, 80, 50, 80] // Adjusted widths
            let headers = ["Date", "Type", "Festival", "Venue", "Artist", "Role", "City", "State", "Desc", "Friends", "URL"]
            
            // Draw header row
            var xPosition = margin
            for (index, header) in headers.enumerated() {
                let rect = CGRect(x: xPosition, y: yPosition, width: columnWidths[index], height: 20)
                
                // Draw background
                UIColor.lightGray.setFill()
                UIRectFill(rect)
                
                // Draw border
                UIColor.black.setStroke()
                let path = UIBezierPath(rect: rect)
                path.lineWidth = 0.5
                path.stroke()
                
                // Draw text
                let headerAttributes: [NSAttributedString.Key: Any] = [
                    .font: headerFont,
                    .foregroundColor: UIColor.black
                ]
                let textRect = CGRect(x: xPosition + 2, y: yPosition + 2, width: columnWidths[index] - 4, height: 16)
                header.draw(in: textRect, withAttributes: headerAttributes)
                
                xPosition += columnWidths[index]
            }
            yPosition += 20
            
            // Draw data rows
            for row in rows {
                // Check if we need a new page
                if yPosition > pageHeight - margin - 20 {
                    context.beginPage()
                    yPosition = margin
                }
                
                let rowData = [
                    row.date,
                    row.type,
                    row.festivalName,
                    row.venueName,
                    row.artistName,
                    row.artistRole,
                    row.city,
                    row.state,
                    truncateText(row.description, maxLength: 30),
                    row.friends,
                    truncateText(row.setlistURL, maxLength: 30)
                ]
                
                xPosition = margin
                for (index, data) in rowData.enumerated() {
                    let rect = CGRect(x: xPosition, y: yPosition, width: columnWidths[index], height: 16)
                    
                    // Draw border
                    UIColor.black.setStroke()
                    let path = UIBezierPath(rect: rect)
                    path.lineWidth = 0.5
                    path.stroke()
                    
                    // Draw text
                    let cellAttributes: [NSAttributedString.Key: Any] = [
                        .font: cellFont,
                        .foregroundColor: UIColor.black
                    ]
                    let textRect = CGRect(x: xPosition + 2, y: yPosition + 2, width: columnWidths[index] - 4, height: 12)
                    data.draw(in: textRect, withAttributes: cellAttributes)
                    
                    xPosition += columnWidths[index]
                }
                yPosition += 16
            }
        }
        
        return data
    }
    
    static func truncateText(_ text: String, maxLength: Int) -> String {
        if text.count > maxLength {
            return String(text.prefix(maxLength - 3)) + "..."
        }
        return text
    }
    
    // MARK: - File Helpers
    
    static func getFileName(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        return "my_concerts_\(dateString).\(format)"
    }
}
