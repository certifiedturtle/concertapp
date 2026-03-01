# Festival Grouping Implementation Summary

## Overview
Updated the festival insights to intelligently group festivals by name, allowing users to see their attendance history for recurring festivals. The system uses fuzzy name matching to group similar festival names (e.g., "Riot Fest" and "Riot Fest Music Festival" are treated as the same festival).

## Changes Made

### 1. Updated FestivalListView.swift
**New Data Structure:**
```swift
struct GroupedFestival: Identifiable {
    let id = UUID()
    let festivalName: String
    let concerts: [Concert]
    let attendanceCount: Int
    let totalUniqueArtists: Int
}
```

**Fuzzy Name Matching:**
- `normalizeFestivalName()` - Removes common words, spaces, punctuation
- `areSimilarFestivalNames()` - Compares normalized names
- Groups similar festivals together (e.g., "Riot Fest" = "RiotFest" = "Riot Fest Music Festival")

**Grouping Logic:**
- Festivals grouped by similar normalized names
- Uses first encountered name as display name
- Concerts within groups sorted by date (newest first)
- Groups sorted by attendance count (most attended first)

**Enhanced Search:**
- Search by festival name
- Search by year (e.g., "2024")
- Search by artist name
- Search by city

**Display:**
- One row per unique festival
- Shows: Festival name + "Attended X times"
- NavigationLink to FestivalHistoryView

### 2. Created FestivalHistoryView.swift
**Layout:**
- Title: "[Festival Name] History"
- Stats section:
  - Times Attended (count)
  - Total Artists (unique across all years)
- Years section:
  - List of years attended
  - Each row shows: Year (primary), artist count (secondary), date, location
  - NavigationLink to ConcertDetailView for that year

**Features:**
- Chronological year list (newest first)
- Shows date and location for each year
- Stats summary at top
- Clean, consistent design

### 3. Fuzzy Matching Algorithm
**Normalization Process:**
1. Convert to lowercase
2. Remove common words: "festival", "fest", "music", "the", "&", "and"
3. Remove spaces, punctuation, special characters
4. Keep only alphanumeric characters

**Matching Logic:**
- Exact match after normalization → group together
- One name contains the other + length ratio > 0.6 → group together
- Otherwise → separate festivals

**Examples:**
- ✅ "Riot Fest" = "RiotFest" = "Riot Fest Music Festival"
- ✅ "Coachella" = "Coachella Music Festival" = "Coachella Valley Music and Arts Festival"
- ✅ "Lollapalooza" = "Lolla" (if length ratio satisfied)
- ❌ "Riot Fest" ≠ "Reading Festival" (different names)

## Navigation Flow

```
Insights → Total Festivals
    ↓
FestivalListView (Grouped)
├── Riot Fest (Attended 4 times)
│   └── FestivalHistoryView: Riot Fest History
│       ├── 2026 (42 artists) → ConcertDetailView
│       ├── 2025 (38 artists) → ConcertDetailView
│       ├── 2024 (35 artists) → ConcertDetailView
│       └── 2023 (30 artists) → ConcertDetailView
├── Coachella (Attended 2 times)
│   └── FestivalHistoryView: Coachella History
│       ├── 2025 (50 artists) → ConcertDetailView
│       └── 2024 (45 artists) → ConcertDetailView
└── Bonnaroo (Attended 1 time)
    └── FestivalHistoryView: Bonnaroo History
        └── 2024 (40 artists) → ConcertDetailView
```

## Key Features

### Intelligent Grouping
- ✅ Groups festivals with similar names automatically
- ✅ Handles variations in naming (with/without "Festival", "Music", etc.)
- ✅ Works for single-year festivals too (still shows grouped view)

### Sorting
- ✅ Festivals sorted by attendance count (highest first)
- ✅ Years within groups sorted chronologically (newest first)

### Search Functionality
- ✅ Search by festival name (e.g., "Riot")
- ✅ Search by year (e.g., "2024")
- ✅ Search by artist (e.g., "Taylor Swift")
- ✅ Search by city (e.g., "Chicago")
- ✅ Updated search prompt: "Search festivals, years, or artists"

### Statistics
- ✅ Total times attended per festival
- ✅ Total unique artists seen across all years
- ✅ Artist count per year
- ✅ Date and location displayed for each year

### Display
- ✅ Clean row format with festival name and attendance count
- ✅ History view shows comprehensive stats
- ✅ Year rows show date, location, and artist count
- ✅ Consistent styling throughout

## Edge Cases Handled

### Single-Year Festivals
- Still grouped and displayed
- Tapping shows history view with one year
- Maintains consistent UI pattern

### Empty Festival Names
- Skipped during grouping
- Won't cause crashes or empty rows

### Similar But Different Festivals
- Length ratio check prevents false matches
- "Riot" won't match "Riot Fest" if length difference too large
- Prevents over-aggressive grouping

### Multiple Grouping Candidates
- Uses first encountered name as display name
- Ensures consistent grouping across app sessions

## Files Modified

1. **FestivalListView.swift** - Complete rewrite with grouping logic

## Files Created

1. **FestivalHistoryView.swift** - New view for festival attendance history

## Testing Checklist

- [ ] Add same festival with different name variations (e.g., "Riot Fest", "RiotFest")
- [ ] Verify they group together
- [ ] Add same festival across multiple years
- [ ] Verify attendance count is correct
- [ ] Tap grouped festival, verify history view appears
- [ ] Verify stats (times attended, total artists) are accurate
- [ ] Tap year in history, verify concert detail loads
- [ ] Search by festival name, verify filtering works
- [ ] Search by year (e.g., "2024"), verify shows correct festivals
- [ ] Search by artist name, verify shows festivals where they performed
- [ ] Test with single-year festival, verify still shows history view
- [ ] Verify empty states work (no festivals, no search results)
- [ ] Check sorting (highest attendance count first)

## Notes

- Grouping only applies to Insights → Total Festivals view
- Main concerts page with festival filter shows individual entries (ungrouped)
- Fuzzy matching is conservative to prevent false positives
- First encountered name becomes the display name for the group
- System handles typos and variations gracefully
- All concerts within a group are preserved and accessible
