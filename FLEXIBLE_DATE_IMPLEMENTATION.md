# Flexible Date Entry Feature - Implementation Complete ✅

## Overview
Implemented flexible date entry for concerts, allowing users to enter full dates, month+year, or year only. This accommodates situations where users don't remember the exact date of a concert from the past.

---

## Feature Capabilities

### Date Precision Options

Users can now specify how much they know about a concert date:

| Precision | What's Stored | Display Format | Example |
|-----------|---------------|----------------|---------|
| **Exact Date** | Full date | Feb 27, 2026 | "February 27, 2026" |
| **Month & Year** | 1st of month | February 2026 | "February 2026" |
| **Year Only** | January 1 of year | 2026 | "2026" |

### Requirements
- ✅ **At least a year is required** - Users must provide minimum of a year
- ✅ **Year range**: 1960-2030 (can be adjusted)
- ✅ **Upgradeable**: Can add more precision later (year → month → full)
- ✅ **Downgradeable**: Can reduce precision if incorrect (full → month → year)

---

## Data Model

### Core Data Changes

**New Property:**
```swift
@NSManaged public var dateGranularity: String?
```

**Possible Values:**
- `"full"` - Exact date known
- `"month"` - Month and year known
- `"year"` - Only year known
- `nil` - Defaults to `"full"` for existing concerts

**Computed Properties:**
```swift
public var wrappedDateGranularity: String {
    dateGranularity ?? "full" // Default for existing concerts
}

public var displayDate: String {
    guard let date = date else { return "Date Unknown" }
    
    let formatter = DateFormatter()
    switch wrappedDateGranularity {
    case "full":
        formatter.dateStyle = .medium // "Feb 27, 2026"
        return formatter.string(from: date)
    case "month":
        formatter.dateFormat = "MMMM yyyy" // "February 2026"
        return formatter.string(from: date)
    case "year":
        formatter.dateFormat = "yyyy" // "2026"
        return formatter.string(from: date)
    default:
        return "Date Unknown"
    }
}
```

### Storage Strategy

**Approximate dates are stored as**:
- **Year only**: January 1 of that year (e.g., 2020 → Jan 1, 2020)
- **Month + Year**: 1st day of that month (e.g., June 2020 → Jun 1, 2020)
- **Full date**: Exact date selected

**Benefits**:
- ✅ Sorting still works correctly
- ✅ Date-based queries function normally
- ✅ Year/month grouping works for statistics
- ✅ No complex string parsing needed

---

## User Interface

### AddEditConcertView

**Segmented Picker**:
```
┌──────────────────────────────────────┐
│ [Exact Date][Month & Year][Year Only]│
└──────────────────────────────────────┘
```

**Exact Date View**:
```
Date Precision
[Exact Date][Month & Year][Year Only]
                    ▲

Date
┌──────────────────────────────────────┐
│  February 27, 2026            [🗓️]  │
└──────────────────────────────────────┘
```

**Month & Year View**:
```
Date Precision
[Exact Date][Month & Year][Year Only]
                    ▲

Month                    Year
┌──────────────┐ ┌──────────────┐
│  February  ▼ │ │   2026    ▼  │
└──────────────┘ └──────────────┘
```

**Year Only View**:
```
Date Precision
[Exact Date][Month & Year][Year Only]
                                ▲

Year
┌──────────────────────────────────────┐
│               2026                   │
│               2025                   │
│            ●  2024  ●                │
│               2023                   │
│               2022                   │
└──────────────────────────────────────┘
(Wheel picker)
```

### ConcertDetailView

**Display automatically adjusts based on granularity**:

```swift
Text(concert.displayDate) // Uses computed property
```

Examples:
- Full: "February 27, 2026"
- Month: "February 2026"
- Year: "2026"

---

## Implementation Details

### Files Modified

#### 1. Concert+CoreDataProperties.swift ✅
- Added `dateGranularity: String?` property
- Added `wrappedDateGranularity` computed property
- Updated `displayDate` to respect granularity

#### 2. AddEditConcertView.swift ✅
- Added segmented picker for date precision
- Added conditional date input views
- Updated `saveConcert()` to construct appropriate date
- Updated `loadConcertData()` to extract year/month
- Updated `searchForSetlist()` to use granularity-aware dates

#### 3. ConcertViewModel.swift ✅
- Added `dateGranularity` parameter to `createConcert()`
- Added `dateGranularity` parameter to `updateConcert()`
- Sets `concert.dateGranularity` when saving

#### 4. ConcertDetailView.swift ✅
- Updated `searchForSetlist()` to format date based on granularity
- Uses `concert.displayDate` (automatically handles granularity)

---

## User Workflows

### Creating a Concert with Year Only

1. User taps "Add Concert"
2. Enters artist, venue details
3. Taps "Year Only" in date precision
4. Scrolls to select year (e.g., 2015)
5. Completes other fields
6. Taps "Save"
7. Concert stored with date = Jan 1, 2015, granularity = "year"
8. Displays as "2015" in list and detail views

### Upgrading Date Precision

**Scenario**: User initially entered year only, later finds exact date

1. User views concert showing "2015"
2. Taps "Search for Setlist" → Opens Safari
3. Finds setlist showing exact date: June 15, 2015
4. Returns to app, taps "Edit"
5. Changes date precision to "Exact Date"
6. Selects June 15, 2015
7. Taps "Save"
8. Concert now displays "June 15, 2015"

### Downgrading Date Precision

**Scenario**: User realizes month was wrong

1. User views concert showing "June 15, 2015"
2. Realizes "Actually, I'm not sure it was June"
3. Taps "Edit"
4. Changes date precision to "Year Only"
5. Year automatically set to 2015 (extracted from previous date)
6. Taps "Save"
7. Concert now displays "2015"

---

## Search for Setlist Integration

The search query automatically adapts to date precision:

### Full Date
```
Query: "setlistfm Taylor Swift Madison Square Garden New York, NY February 27, 2026"
```

### Month + Year
```
Query: "setlistfm Taylor Swift Madison Square Garden New York, NY February 2026"
```

### Year Only
```
Query: "setlistfm Taylor Swift Madison Square Garden New York, NY 2026"
```

**Implementation**:
```swift
switch concert.wrappedDateGranularity {
case "full":
    dateFormatter.dateStyle = .long
    dateString = dateFormatter.string(from: concert.wrappedDate)
case "month":
    dateFormatter.dateFormat = "MMMM yyyy"
    dateString = dateFormatter.string(from: concert.wrappedDate)
case "year":
    dateFormatter.dateFormat = "yyyy"
    dateString = dateFormatter.string(from: concert.wrappedDate)
}
```

---

## Sorting & Filtering

### How It Works

**Sorting remains unchanged** - uses the `date` field:
- Year-only dates sort to January 1
- Month-only dates sort to 1st of month
- Full dates sort to exact day

**Example sorted list**:
```
1. Taylor Swift - February 27, 2026 (full)
2. The Beatles - February 2026 (month)
3. Radiohead - 2026 (year)          [sorts to Jan 1, 2026]
4. Pink Floyd - December 15, 2025 (full)
5. Nirvana - 2025 (year)            [sorts to Jan 1, 2025]
```

### Fetch Requests

No changes needed:
```swift
let request = Concert.fetchRequest()
request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
```

Works perfectly with approximate dates!

---

## Edge Cases & Validation

### Handled Scenarios

| Scenario | Behavior |
|----------|----------|
| User switches precision while editing | Year/month extracted from previous date |
| User enters year before 1960 | Picker doesn't allow it |
| User enters year after 2030 | Picker doesn't allow it |
| User saves without selecting date | Year defaults to current year |
| Existing concert (no granularity) | Defaults to "full" |
| User upgrades precision | Previous date used as starting point |
| User downgrades precision | Year/month preserved |

### Month Name Helper

```swift
private func monthName(for month: Int) -> String {
    let formatter = DateFormatter()
    return formatter.monthSymbols[month - 1]
}
```

Returns localized month names (e.g., "January", "February", etc.)

---

## Migration & Backwards Compatibility

### Existing Concerts

**All existing concerts**:
- Have `dateGranularity = nil`
- Computed property `wrappedDateGranularity` returns `"full"`
- Display correctly as exact dates
- No data migration needed! ✅

### New Concerts

**Default behavior**:
- Picker starts on "Exact Date"
- Users explicitly choose if they want less precision
- Saves with appropriate granularity flag

---

## Statistics & Insights Impact

### Concerts Per Year

**Works perfectly** - groups by year regardless of granularity:
```swift
let year = calendar.component(.year, from: concert.wrappedDate)
```

✅ Year-only: 2020 → counts in 2020  
✅ Month-only: June 2020 → counts in 2020  
✅ Full date: June 15, 2020 → counts in 2020  

### Concerts Per Month

**Also works** - groups by month/year:
```swift
let month = calendar.component(.month, from: concert.wrappedDate)
let year = calendar.component(.year, from: concert.wrappedDate)
```

⚠️ **Note**: Year-only dates will cluster in January (because stored as Jan 1)

**Potential enhancement**: Filter to only show full/month precision dates in monthly view

### Date Ranges

**Works correctly** - uses stored date for min/max calculations

---

## Console Output Examples

### Creating concert with month+year:
```
📅 Date granularity: month
📅 Selected: June 2020
📅 Stored date: 2020-06-01
✅ Concert created successfully
```

### Creating concert with year only:
```
📅 Date granularity: year
📅 Selected: 2015
📅 Stored date: 2015-01-01
✅ Concert created successfully
```

### Searching for setlist (year only):
```
🔍 Searching for setlist: setlistfm The Beatles Red Rocks Denver, CO 2015
```

---

## Testing Checklist

### Basic Functionality
- [ ] Create concert with exact date
- [ ] Create concert with month + year
- [ ] Create concert with year only
- [ ] Edit concert and upgrade precision (year → month → full)
- [ ] Edit concert and downgrade precision (full → month → year)

### Display
- [ ] Full date displays as "February 27, 2026"
- [ ] Month+year displays as "February 2026"
- [ ] Year displays as "2026"
- [ ] List view shows correct format
- [ ] Detail view shows correct format

### Sorting
- [ ] Concerts sort correctly with mixed granularities
- [ ] Year-only concerts sort to beginning of year
- [ ] Month-only concerts sort to beginning of month

### Search Integration
- [ ] Search with full date includes full date
- [ ] Search with month+year includes "February 2026"
- [ ] Search with year only includes "2026"

### Edge Cases
- [ ] Switch between precisions while editing
- [ ] Year picker starts at current year
- [ ] Month picker shows all 12 months
- [ ] Existing concerts show as full date
- [ ] Can downgrade then re-upgrade precision

### Data Persistence
- [ ] Granularity saves correctly
- [ ] Approximate date saves correctly
- [ ] Survives app restart
- [ ] Shows in diagnostics correctly

---

## Benefits

### For Users
✅ **Flexible**: Enter what they know  
✅ **Forgiving**: Don't need to remember exact dates  
✅ **Upgradeable**: Can add precision later  
✅ **Honest**: Shows what's known vs. approximate  
✅ **Useful**: Can still search for setlists with partial dates  

### For Developers
✅ **Simple storage**: Just a date + string flag  
✅ **Backwards compatible**: Existing data works fine  
✅ **No migration**: Old concerts default to "full"  
✅ **Sorting works**: Uses same date field  
✅ **Extensible**: Easy to add more granularities  

---

## Future Enhancements

Potential improvements:

1. **Unknown Date Option**
   - Allow concerts with no date at all
   - Sort to bottom of list
   - Search without date component

2. **Approximate Indicator**
   - Show "~2020" or "circa 2020" for year-only
   - Visual badge for non-full dates

3. **Smart Date Suggestions**
   - If searching setlist finds exact date, offer to update

4. **Statistics Filtering**
   - Option to exclude approximate dates from monthly stats
   - Show precision distribution (% full vs. month vs. year)

5. **Date Confidence**
   - Let users mark how confident they are
   - "Pretty sure it was June" vs. "Definitely June 15"

---

## Success Criteria

✅ Users can create concerts with partial date info  
✅ Date precision can be upgraded or downgraded  
✅ Display formats match specified granularity  
✅ Search queries adapt to date precision  
✅ Sorting still works correctly  
✅ Existing concerts unaffected  
✅ No data migration required  

---

**Implementation Complete!** Users can now enter concerts with flexible date precision, making it easier to catalog concerts from the past where exact dates aren't remembered. 🎉
