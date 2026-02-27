# Festival Date Display Fixes

## Issues Fixed

### Issue 1: Dates showing as just numbers (e.g., "5, 7")
**Problem**: When attending non-consecutive days, the dates were only showing day numbers without the month.

**Solution**: Updated `displayDateRange` to use `.medium` date style for non-consecutive dates, showing full dates like "Feb 5, 2026, Feb 7, 2026" instead of just "5, 7".

### Issue 2: Main page showing too much detail
**Problem**: The list view was showing the full date range or attended dates, which could be cluttered.

**Solution**: Added new `listDisplayDate` property that:
- For festivals: Shows only the start date (e.g., "Feb 5, 2026")
- For concerts: Shows the regular date (respecting date granularity)

### Issue 3: Festival end date not saving when beyond attended dates
**Problem**: If a festival ran Feb 5-8 but you only attended Feb 5 and 7, the end date (Feb 8) wasn't being saved.

**Solution**: Changed the save logic to save `festivalEndDate` directly instead of calculating it from attended dates.

```swift
// Before:
concertToSave.endDate = sortedDates.last ?? festivalEndDate

// After:
concertToSave.endDate = festivalEndDate
```

## Display Changes

### List View (ConcertRowView)
- **Before**: "February 5, 7" (confusing)
- **After**: "Feb 5, 2026" (clean, just start date)

### Detail View
- **Consecutive attendance**: "February 5-8" (unchanged, works well)
- **Non-consecutive attendance**: 
  - **Before**: "5, 7" (confusing)
  - **After**: "Feb 5, 2026, Feb 7, 2026" (clear and complete)
- **Single day**: "Feb 5, 2026" (unchanged)

## Technical Changes

### Concert+CoreDataProperties.swift

#### New Property
```swift
public var listDisplayDate: String {
    guard let startDate = date else { return "Date Unknown" }
    
    if isFestival {
        // For festivals in list view, just show start date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: startDate)
    }
    
    // For regular concerts, use normal display
    return displayDate
}
```

#### Updated Property
```swift
public var displayDateRange: String {
    // ...
    // For non-consecutive dates, use .medium date style
    formatter.dateStyle = .medium
    let dateStrings = sortedDates.map { formatter.string(from: $0) }
    return dateStrings.joined(separator: ", ")
    // ...
}
```

### ConcertsListView.swift
```swift
// Changed from:
Text(concert.displayDateRange)

// To:
Text(concert.listDisplayDate)
```

### AddEditConcertView.swift
```swift
// Changed from:
concertToSave.endDate = sortedDates.last ?? festivalEndDate

// To:
concertToSave.endDate = festivalEndDate
```

## Examples

### Example 1: Consecutive Attendance
- Festival: February 5-8, 2026
- Attended: All days (Feb 5, 6, 7, 8)
- **List view**: "Feb 5, 2026"
- **Detail view**: "February 5-8"

### Example 2: Non-Consecutive Attendance
- Festival: February 5-8, 2026
- Attended: Friday and Sunday (Feb 5, 7)
- **List view**: "Feb 5, 2026"
- **Detail view**: "Feb 5, 2026, Feb 7, 2026"

### Example 3: Single Day
- Festival: February 5, 2026
- Attended: Feb 5
- **List view**: "Feb 5, 2026"
- **Detail view**: "Feb 5, 2026"

### Example 4: Partial Attendance with Later End Date
- Festival: February 5-10, 2026
- Attended: Feb 5, 7, 8
- Festival end date (Feb 10) is now properly saved
- **List view**: "Feb 5, 2026"
- **Detail view**: "Feb 5, 2026, Feb 7, 2026, Feb 8, 2026"

## Benefits

1. **Cleaner List View**: Just shows start date, less visual clutter
2. **Clear Detail View**: Full dates make it obvious which specific days you attended
3. **Accurate Data**: Festival end date is preserved even if not attended
4. **Consistent Format**: Uses standard iOS date formats (.medium style)
5. **Cross-Month Support**: If a festival spans months, it shows the month for each date
