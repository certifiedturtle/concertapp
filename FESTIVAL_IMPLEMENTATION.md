# Festival Support Implementation

## Overview
This document outlines all the changes made to support festivals in the Concert App. Festivals are treated differently from standard concerts with multi-day attendance, larger artist lineups, and different display requirements.

## Changes Made

### 1. Core Data Model Updates (`Concert+CoreDataProperties.swift`)

#### New Properties Added:
- `festivalName: String?` - The name of the festival
- `endDate: Date?` - For multi-day consecutive attendance
- `attendedDates: String?` - Comma-separated ISO8601 date strings for non-sequential attendance

#### New Computed Properties:
- `wrappedFestivalName` - Safe unwrapping of festival name
- `attendedDatesArray` - Parsed array of attended dates
- `displayDateRange` - Smart date formatting:
  - Sequential dates: "August 10-14"
  - Non-sequential dates: "August 10, 12, 14"
  - Single day or regular concert: falls back to `displayDate`
- `listDisplayName` - Returns "Festival Name YEAR" for festivals, artist name for concerts

#### Modified Properties:
- `primaryArtistName` - Now returns festival name when `isFestival == true`

---

### 2. Add/Edit View (`AddEditConcertView.swift`)

#### New State Variables:
- `festivalName: String` - Festival name input
- `hasEndDate: Bool` - Toggle for multi-day consecutive attendance
- `endDate: Date` - End date for consecutive days
- `useSpecificDates: Bool` - Toggle for non-sequential dates
- `specificDates: [Date]` - Array of specific dates attended

#### UI Changes:
**Festival Mode (when `isFestival` selected):**
- Shows "Festival Name" text field
- Hides venue name field (festivals don't have venues)
- Shows start date picker
- Shows "Multi-day attendance" toggle with options:
  - **Consecutive days**: Shows end date picker
  - **Specific days**: Shows dynamic list of date pickers for non-sequential attendance
- Hides headliner toggle for artists
- Adds helper text: "Add all artists performing at the festival"
- Hides setlist search functionality
- Return key on artist text field automatically adds new artist row

**Standard Concert Mode:**
- Keeps all existing functionality unchanged
- Date granularity options (exact date, month, year)
- Venue field required
- Headliner toggles for multiple artists
- Setlist search available

#### Validation:
- Festivals: Requires `festivalName` and at least one artist
- Concerts: Requires `venueName` and at least one artist

#### Save Logic:
- Stores attended dates as comma-separated ISO8601 strings
- Sets `isHeadliner = false` for all festival artists
- Properly handles both create and update operations
- Clears festival-specific fields when saving concerts, and vice versa

---

### 3. Detail View (`ConcertDetailView.swift`)

#### Display Changes:

**Header:**
- Shows festival name instead of artist name when `isFestival == true`
- Displays date range using `displayDateRange` property

**Venue Section:**
- Hides venue name for festivals
- Shows only City, State with primary styling (larger font)

**Artists Section:**
- Changes title to "Lineup" for festivals
- Always shows all artists for festivals (not just when count > 1)
- Hides headliner stars for festival artists

**Setlist:**
- Completely hidden for festivals (as requested)

---

### 4. List View (`ConcertsListView.swift`)

#### New Features:

**Filter Menu:**
- Added to leading toolbar position
- Three options:
  - **All** - Shows everything (default)
  - **Concerts Only** - Filters out festivals
  - **Festivals Only** - Shows only festivals

**Row Display:**
- Shows `listDisplayName` (e.g., "Lollapalooza 2025" for festivals)
- Displays 🎪 circus tent icon (`tent.fill`) next to festival names
- Shows `displayDateRange` for proper multi-day formatting
- Hides venue for festivals, shows only location (City, State)

#### Search:
- Updated to search against `listDisplayName` instead of just `primaryArtistName`
- Works with both concerts and festivals

---

### 5. Insights View (`InsightsView.swift`)

#### New Statistics:
- **Total Festivals** - Count of all festivals attended
  - Orange tent icon
  - Positioned after "Concerts This Year"

#### Updated Statistics:
- **Unique Artists** - Includes artists from both concerts AND festivals
- **Unique Venues** - Only counts non-festival concerts (as intended)
- **Unique Cities** - Includes both concerts and festivals

#### View Model:
- Added `InsightsViewModel` class with all calculation logic
- Properly filters festivals vs concerts for accurate stats
- Uses case-insensitive matching for uniqueness calculations

---

## Core Data Migration

### ⚠️ IMPORTANT: You need to update your Core Data model in Xcode

Since we added new properties to the Concert entity, you need to:

1. Open your `.xcdatamodeld` file in Xcode
2. Add these three new attributes to the Concert entity:
   - `festivalName` - Type: String, Optional
   - `endDate` - Type: Date, Optional
   - `attendedDates` - Type: String, Optional

3. For development (with test data), you can either:
   - **Option A**: Delete and reinstall the app (loses all data)
   - **Option B**: Create a new model version and add a migration (preserves data)

### Adding the attributes in Xcode:
```
1. Select Concert entity
2. Click + button in Attributes section
3. Add: festivalName (String, Optional)
4. Add: endDate (Date, Optional)
5. Add: attendedDates (String, Optional)
6. Save the model
```

---

## Usage Examples

### Adding a Festival

1. Tap + to add new concert
2. Select "Festival" type
3. Enter festival name (e.g., "Lollapalooza")
4. Add artists (return key adds new row quickly)
5. Select start date
6. Choose attendance pattern:
   - **Single day**: Leave toggles off
   - **Multiple consecutive days**: Enable "Multiple consecutive days" and pick end date
   - **Non-sequential days**: Enable "Multi-day attendance" and add specific dates

### Festival Display

**In List:**
- "Lollapalooza 2025" 🎪
- "August 10-14"
- "Chicago, IL"

**In Detail View:**
- Title: "Lollapalooza"
- Date: "August 10-14" (or "August 10, 12, 14" for non-sequential)
- Location: "Chicago, IL" (no venue)
- Lineup: All artists listed
- No setlist search button

### Filtering

- Use filter button (top-left) to toggle between:
  - All events
  - Concerts only
  - Festivals only

---

## Technical Notes

### Date Storage
- `date`: Always stores the start date
- `endDate`: Used for consecutive multi-day attendance
- `attendedDates`: Used for non-sequential days (stored as ISO8601 comma-separated string)
- Priority: `attendedDates` > `endDate` > `date` (for display)

### Artist Handling
- Festival artists: All have `isHeadliner = false`
- Concert artists: Support headliner designation
- Both types included in "Unique Artists" stat

### Search & Filter
- `listDisplayName` handles display logic
- Filters work independently of search
- Both can be combined

---

## Future Enhancements (Not Implemented)

These were discussed but postponed:

1. **Bulk artist import** - Paste comma/line-separated list
2. **Photo organization by day** - For multi-day festivals
3. **Per-artist setlist search** - For festivals
4. **Festival-specific insights** - Average artists per festival, etc.

---

## Testing Checklist

- [ ] Add a single-day festival
- [ ] Add a multi-day consecutive festival (e.g., Thu-Sun)
- [ ] Add a festival with non-sequential days (e.g., Thu & Sat only)
- [ ] Edit an existing festival
- [ ] Convert concert to festival (and vice versa)
- [ ] Filter by concerts only
- [ ] Filter by festivals only
- [ ] Search for festivals
- [ ] Verify insights include festival artists
- [ ] Verify unique venues doesn't count festivals
- [ ] Delete a festival
- [ ] Add photos to festivals

---

## Files Modified

1. `Concert+CoreDataProperties.swift` - Data model and computed properties
2. `AddEditConcertView.swift` - Festival entry UI and save logic
3. `ConcertDetailView.swift` - Festival display logic
4. `ConcertsListView.swift` - Filtering and row display
5. `InsightsView.swift` - Festival statistics

## Files Created

1. `FESTIVAL_IMPLEMENTATION.md` - This document

---

**Status**: ✅ Implementation Complete  
**Next Step**: Update Core Data model in Xcode with the three new attributes
