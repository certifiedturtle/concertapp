# Concert Export and Backup Implementation Summary

## Overview
Implemented comprehensive export and backup functionality for concert data in both PDF and CSV formats. The system creates spreadsheet-style exports with one row per artist per concert, maintaining data consistency and readability.

## Files Created

### 1. ConcertExportManager.swift
**New utility class for export operations:**
- Data preparation and formatting
- PDF generation with table layout
- CSV generation with proper escaping
- Date formatting based on granularity
- File naming with timestamps

## Files Modified

### 1. SettingsView.swift
**Updated with full export/backup functionality:**
- Added Core Data fetch request for concerts
- Added state variables for sheets and alerts
- Implemented "Export Concert Data" button
- Implemented "Backup to Files" button
- Added helper structs (ShareSheet, DocumentPicker)
- Error handling and success notifications

## Key Features

### Export Concert Data
**User Flow:**
1. Tap "Export Concert Data"
2. Action sheet appears with "PDF" or "CSV" options
3. Select format
4. iOS share sheet appears
5. Choose destination (AirDrop, Email, Files, etc.)

**What Gets Exported:**
- Date (respecting granularity)
- Concert type (Standard/Festival)
- Festival name (if applicable)
- Venue name (if applicable)
- Artist name
- Artist role (Headliner/Opener/Festival)
- City
- State
- Description/notes
- Friends tags
- Setlist URL

### Backup to Files
**User Flow:**
1. Tap "Backup to Files"
2. Both PDF and CSV generated automatically
3. iOS file picker appears
4. User selects folder
5. Both files saved
6. Success notification appears (dismisses after 3 seconds)

## Data Format

### Spreadsheet-Style Layout
**One row per artist per concert:**
```
Example Concert with 3 artists:
Row 1: [Date] [Type] [Festival] [Venue] [Artist 1] [Role] [City] [State] [Desc] [Friends] [URL]
Row 2: [Date] [Type] [Festival] [Venue] [Artist 2] [Role] [City] [State] [Desc] [Friends] [URL]
Row 3: [Date] [Type] [Festival] [Venue] [Artist 3] [Role] [City] [State] [Desc] [Friends] [URL]
```

**Real Example:**
```
2026-02-27 | Standard | | MSG | Taylor Swift | Headliner | New York | NY | Amazing! | John, Sarah | http://... |
2026-02-27 | Standard | | MSG | Gracie Abrams | Opener | New York | NY | Amazing! | John, Sarah | http://... |
2025-09-15 | Festival | Riot Fest | | Blink-182 | Festival | Chicago | IL | | Mike | |
2025-09-15 | Festival | Riot Fest | | Green Day | Festival | Chicago | IL | | Mike | |
```

### PDF Format
**Structure:**
- Title: "My Concert History: X Concerts"
- Table with 11 columns
- Headers: Date, Type, Festival, Venue, Artist, Role, City, State, Desc, Friends, URL
- Small font (7-8pt) to fit all columns
- Borders on all cells
- Gray header background
- Multi-page support
- Sorted newest first

**Column Widths:**
- Date: 60pt
- Type: 40pt
- Festival: 60pt
- Venue: 80pt
- Artist: 80pt
- Role: 45pt
- City: 50pt
- State: 30pt
- Description: 80pt (truncated with ...)
- Friends: 50pt
- URL: 80pt (truncated with ...)

### CSV Format
**Structure:**
- Header row with column names
- Comma-separated values
- Proper escaping for commas, quotes, newlines
- UTF-8 encoding
- One row per artist per concert

**Example CSV:**
```csv
Date,Type,Festival Name,Venue Name,Artist Name,Artist Role,City,State,Description,Friends,Setlist URL
2026-02-27,Standard,,Madison Square Garden,Taylor Swift,Headliner,New York,NY,"Amazing show!","John, Sarah",https://...
2026-02-27,Standard,,Madison Square Garden,Gracie Abrams,Opener,New York,NY,"Amazing show!","John, Sarah",https://...
```

## File Naming
**Format:** `my_concerts_YYYY-MM-DD.{pdf|csv}`

**Examples:**
- `my_concerts_2026-03-01.pdf`
- `my_concerts_2026-03-01.csv`

## Helper Components

### ShareSheet
**UIViewControllerRepresentable wrapper:**
- Wraps UIActivityViewController
- Presents standard iOS share sheet
- Supports all sharing methods (AirDrop, Mail, Messages, Save to Files, etc.)

### DocumentPicker
**UIViewControllerRepresentable wrapper:**
- Wraps UIDocumentPickerViewController
- Allows user to choose save location
- Supports exporting multiple files at once
- Delegates success/cancel callbacks

## Error Handling

### No Concerts to Export
- Shows alert: "No concerts to export"
- Prevents empty file generation

### PDF Generation Failed
- Shows alert: "Failed to generate PDF"
- Logs error for debugging

### CSV Generation Failed
- Shows alert: "Failed to save CSV"
- Logs error for debugging

### Backup Failed
- Shows alert: "Save failed. Please try again."
- User can retry the operation

### User Cancels
- No error shown
- Operation silently cancelled

## Success Notifications

### Backup Success
- Green checkmark icon
- "Backup saved to Files" text
- Appears at bottom of screen
- Dismisses automatically after 3 seconds
- Smooth spring animation

## Special Handling

### Date Formatting
**Respects date granularity:**
- Full date: "2026-02-27" (YYYY-MM-DD)
- Month/year: "February 2026"
- Year only: "2026"
- Unknown: "2026" (fallback to year)

### Empty Fields
**All empty fields left blank:**
- No "N/A" or "None" placeholders
- Clean, professional appearance
- CSV: empty strings between commas
- PDF: empty cells

### Long Text Truncation
**PDF only:**
- Description: 30 characters max + "..."
- Setlist URL: 30 characters max + "..."
- Keeps table readable
- Full text preserved in CSV

### Festival vs Standard Concerts
**Automatic handling:**
- Festivals: Festival name filled, venue blank
- Standard: Venue filled, festival name blank
- Artist roles adjust automatically
- No manual logic needed

### Artists Without Concert
**Edge case handling:**
- If concert has no artists: Single row with concert info
- Artist name and role fields left blank
- Prevents empty exports

## Technical Details

### PDF Generation
- Uses UIGraphicsPDFRenderer
- Letter size: 612 x 792 points (8.5" x 11")
- 0.5" margins (36 points)
- Automatic page breaks
- Table borders with 0.5pt stroke
- Metadata: Creator, Author, Title

### CSV Escaping
**Proper RFC 4180 compliance:**
- Fields with commas wrapped in quotes
- Internal quotes doubled ("")
- Newlines within fields preserved
- UTF-8 encoding

### Temporary Files
**Location:**
- PDF/CSV generated in `FileManager.temporaryDirectory`
- Automatically cleaned up by system
- Not stored permanently until user saves

### Memory Management
- Streams data for large exports
- Doesn't load entire PDF into memory
- Efficient for hundreds of concerts

## Testing Checklist

- [ ] Export 1 concert to PDF
- [ ] Export multiple concerts to PDF
- [ ] Verify PDF table formatting
- [ ] Export to CSV
- [ ] Open CSV in spreadsheet app (Excel, Numbers)
- [ ] Verify one row per artist
- [ ] Test festival with many artists (20+)
- [ ] Test concert with special characters in notes
- [ ] Test with commas, quotes, newlines in fields
- [ ] Test date granularity (full, month, year)
- [ ] Share PDF via AirDrop
- [ ] Share CSV via Mail
- [ ] Backup to iCloud Drive
- [ ] Backup to "On My iPhone"
- [ ] Verify both files saved in backup
- [ ] Test with empty description
- [ ] Test with empty friends
- [ ] Test with no setlist URL
- [ ] Verify success notification appears and disappears
- [ ] Test with 0 concerts (should show error)
- [ ] Cancel document picker (should not error)
- [ ] Test with 100+ concerts (performance)

## Known Limitations

### PDF Column Width
- Fixed widths may not be perfect for all screen sizes
- Very long venue/artist names may get cut off
- Consider rotating to landscape for more space (future enhancement)

### Multi-page Breaks
- Rows may split across pages mid-concert
- Could improve with concert grouping (future enhancement)

### File Size
- Large concert collections (500+) may create large PDFs
- CSV will always be smaller
- Consider compression for very large exports (future enhancement)

## Future Enhancements

### Potential Improvements
- [ ] Add landscape orientation option for PDF
- [ ] Custom column selection (user picks which fields to export)
- [ ] Export date range filter
- [ ] Export specific artists/venues only
- [ ] Email export directly from app
- [ ] Scheduled automatic backups
- [ ] Cloud backup to iCloud/Dropbox
- [ ] Import from CSV (reverse operation)
- [ ] Excel format (.xlsx) support
- [ ] JSON format for developers

## User Benefits

### Data Portability
- ✅ Export data to any app or service
- ✅ Share concert history with friends
- ✅ Backup before device upgrade
- ✅ Archive data externally

### Professional Presentation
- ✅ Clean spreadsheet format
- ✅ Print-ready PDFs
- ✅ Easy to analyze in Excel/Numbers
- ✅ Compatible with any system

### Data Safety
- ✅ Multiple backup options
- ✅ User controls where data is saved
- ✅ No cloud dependency
- ✅ Full ownership of data

## Notes

- Export format designed for maximum compatibility
- One row per artist ensures no data loss
- All date formats preserved based on user entry
- Files named with timestamps to prevent overwrites
- iOS native share sheet provides maximum flexibility
- Success feedback ensures user confidence
- Error messages guide user to resolution
