# Concert App - Setup Instructions

## Core Data Model Setup

You need to create a Core Data model file in Xcode to complete the setup:

### Steps:

1. **Create the Data Model File:**
   - In Xcode, go to `File > New > File`
   - Choose `Data Model` under Core Data section
   - Name it **`ConcertApp`** (must match the name in PersistenceController.swift)
   - Save it in your project

2. **Create the Concert Entity:**
   - Click the `+` button at the bottom or go to `Editor > Add Entity`
   - Name it: `Concert`
   - Add these attributes:
     - `id` - UUID
     - `date` - Date
     - `venueName` - String (Optional)
     - `city` - String (Optional)
     - `state` - String (Optional)
     - `concertDescription` - String (Optional)
     - `setlistURL` - String (Optional)
     - `concertType` - String (Optional)
     - `friendsTags` - String (Optional)
   
   - Add relationships:
     - `artists` - To-Many relationship to `Artist`, Delete Rule: Cascade
     - `photos` - To-Many relationship to `ConcertPhoto`, Delete Rule: Cascade

3. **Create the Artist Entity:**
   - Add another entity named: `Artist`
   - Add these attributes:
     - `id` - UUID
     - `name` - String (Optional)
     - `isHeadliner` - Boolean (default value: NO)
   
   - Add relationship:
     - `concert` - To-One relationship to `Concert`, Delete Rule: Nullify

4. **Create the ConcertPhoto Entity:**
   - Add another entity named: `ConcertPhoto`
   - Add these attributes:
     - `id` - UUID
     - `photoIdentifier` - String (Optional)
     - `dateAdded` - Date (Optional)
     - `isVideo` - Boolean (default value: NO)
   
   - Add relationship:
     - `concert` - To-One relationship to `Concert`, Delete Rule: Nullify

5. **Configure Code Generation:**
   - Select each entity one by one
   - In the Data Model Inspector (right panel), find "Codegen"
   - Set it to **"Manual/None"** (we've already created the classes)

6. **Set up inverse relationships:**
   - Select `Concert` entity → `artists` relationship → set Inverse to `concert`
   - Select `Concert` entity → `photos` relationship → set Inverse to `concert`
   - Select `Artist` entity → `concert` relationship → set Inverse to `artists`
   - Select `ConcertPhoto` entity → `concert` relationship → set Inverse to `photos`

## Info.plist Configuration

Add these privacy usage descriptions to your Info.plist:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photos so you can attach concert memories to your events.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save photos from your concerts.</string>
```

In Xcode 15+, you can also add these through:
- Target settings → Info tab → Custom iOS Target Properties
- Add "Privacy - Photo Library Usage Description"
- Add "Privacy - Photo Library Additions Usage Description"

## Project Structure

Your app now includes:

### Core Data Layer:
- `PersistenceController.swift` - Core Data stack management
- `Concert+CoreDataClass.swift` & `Concert+CoreDataProperties.swift` - Concert entity
- `Artist+CoreDataClass.swift` & `Artist+CoreDataProperties.swift` - Artist entity  
- `ConcertPhoto+CoreDataClass.swift` & `ConcertPhoto+CoreDataProperties.swift` - Photo entity

### ViewModels:
- `ConcertViewModel.swift` - Handles concert CRUD operations
- `InsightsViewModel.swift` - Calculates statistics and insights

### Views:
- `MainTabView.swift` - Main tab bar navigation
- `ConcertsListView.swift` - Home screen showing all concerts
- `AddEditConcertView.swift` - Form to add/edit concerts
- `ConcertDetailView.swift` - Detailed view of a single concert
- `PhotoGridView.swift` - Photo grid and full screen photo viewer
- `InsightsView.swift` - Statistics and insights dashboard
- `SettingsView.swift` - App settings and preferences

## Features Implemented:

✅ Local Core Data storage (no cloud/backend needed)
✅ Add/Edit/Delete concerts
✅ Support for standard concerts and festivals
✅ Multiple artists per concert with headliner designation
✅ Photo/video attachment from device library
✅ Free-form friend tags
✅ Venue, city, state, date tracking
✅ Notes/descriptions
✅ Setlist URL linking
✅ Search functionality
✅ Core statistics/insights:
   - Total concerts attended
   - Total unique artists
   - Total unique venues
   - Total unique cities  
   - Concerts this year
✅ Settings page foundation
✅ Native SwiftUI + iOS design

## Next Steps / Future Enhancements:

- Implement data export/backup in Settings
- Add "delete all data" confirmation dialog
- Add filtering by friends, artists, venues, cities
- Add sorting options based on user preferences
- Expand insights with more fun stats
- Add map view of concert locations
- Add concert reminders/notifications
- Add rating system for concerts

## Building and Running:

1. Open the project in Xcode
2. Create the Core Data model file following instructions above
3. Build and run on simulator or device
4. When prompted, allow photo library access to attach concert photos

Enjoy cataloging your concert memories! 🎸🎤🎵
