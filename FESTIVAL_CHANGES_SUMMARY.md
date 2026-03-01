# Festival Entry Changes - Implementation Summary

## Overview
Updated the Concert App to properly handle festivals with dedicated festival names instead of using venue names. Festivals now display with their name + year throughout the app.

## Changes Made

### 1. Core Data Model (`Concert+CoreDataProperties.swift`)
- ✅ Added `festivalName: String?` property
- ✅ Added `wrappedFestivalName` computed property
- ✅ Added `festivalDisplayName` computed property that returns "Festival Name YYYY"

### 2. Add/Edit Concert Form (`AddEditConcertView.swift`)
- ✅ Added `@State private var festivalName = ""`
- ✅ Updated Details section to show festival name field when `concertType == "festival"`
- ✅ Hidden venue name field for festivals
- ✅ Removed headliner/opener toggles for festival artists
- ✅ Updated validation to require festival name for festivals (instead of venue)
- ✅ Updated `loadConcertData()` to load festival name
- ✅ Updated `saveConcert()` to pass festival name

### 3. Concert View Model (`ConcertViewModel.swift`)
- ✅ Added `festivalName` parameter to `createConcert()`
- ✅ Added `festivalName` parameter to `updateConcert()`
- ✅ Both methods now save the festival name to Core Data

### 4. Concerts List View (`ConcertsListView.swift`)
- ✅ Updated `ConcertRowView` to display festival name + year for festivals
- ✅ For festivals: Shows "Festival Name YYYY" as primary text
- ✅ For festivals: Shows "City, State" (no venue)
- ✅ For standard concerts: Shows artist name and venue (unchanged)
- ✅ Updated search filter to include festival names

### 5. Concert Detail View (`ConcertDetailView.swift`)
- ✅ Updated header to show festival name + year for festivals
- ✅ Updated venue section to show only location for festivals (no venue label)
- ✅ Updated artists section to remove headliner stars for festival artists
- ✅ All artists at festivals now shown with music note icon (no headliner distinction)

### 6. Artist Concert Row (`ArtistConcertsView.swift`)
- ✅ Updated `ArtistConcertRowView` to display festival name + year instead of venue
- ✅ Maintains "Festival" badge for easy identification

## Key Features

### Festival Entry Flow
1. Toggle "Festival" in concert type picker
2. Venue field is hidden, festival name field appears
3. Enter festival name (e.g., "Coachella")
4. Year is automatically extracted from the date field
5. Add artists (no headliner/opener distinction needed)
6. City and state still tracked for location

### Display Behavior

#### List Views
- **All Concerts**: "Coachella 2026" + "Indio, CA"
- **Festivals Only**: Same as above
- **Standard Concerts**: "Artist Name" + "Venue • City, State" (unchanged)

#### Detail View
- **Title**: "Coachella 2026" (large, bold)
- **Location**: "Indio, CA" with location icon
- **Artists**: Listed with music note icons (no headliner distinction)

#### Artist Views
- When viewing an artist's concerts, festivals show as "Coachella 2026" with "Festival" badge
- Standard concerts still show venue name

## Data Model Notes

### Core Data Entity: Concert
**New Property:**
- `festivalName: String?` - Stores the name of the festival

**Existing Properties Still Used:**
- `concertType: String?` - "standard" or "festival"
- `venueName: String?` - Ignored for festivals
- `city: String?` - Used for both concerts and festivals
- `state: String?` - Used for both concerts and festivals
- `date: Date?` - Year extracted for festival display

### Migration Strategy
- No migration code added (user will handle manually)
- Existing festivals may have empty `festivalName` field
- App will display empty string for old festivals until edited

## Testing Checklist

- [ ] Open Core Data model (.xcdatamodeld) and add `festivalName` attribute (String, Optional)
- [ ] Clean build folder (Shift+Cmd+K)
- [ ] Delete app from simulator/device
- [ ] Build and run
- [ ] Add a new festival with name
- [ ] Verify festival shows with name + year in all views
- [ ] Add a standard concert
- [ ] Verify standard concert still works as before
- [ ] Test editing both festival and standard concert

## Important: Core Data Schema Update Required

⚠️ **Before running the app, you must:**

1. Open `Concert.xcdatamodeld` in Xcode
2. Select the Concert entity
3. Add a new attribute:
   - **Name**: `festivalName`
   - **Type**: String
   - **Optional**: Yes (checked)
4. Save the model file
5. Clean build (Shift+Cmd+K)
6. Delete app from simulator/device (to reset Core Data)
7. Build and run

Without this step, the app will crash because the code references a property that doesn't exist in the Core Data model.
