# Festival Date Entry Redesign

## Overview
The festival date entry process has been redesigned to be more intuitive and streamlined. Users now input festival start and end dates, then select which specific days they attended from a list.

## Key Changes

### Removed Components
- ❌ "Multi-day attendance" toggle
- ❌ "Multiple consecutive days" toggle
- ❌ Manual date entry for non-sequential days

### New Components
- ✅ **Festival Start Date** (mandatory)
- ✅ **Festival End Date** (mandatory, must be >= start date)
- ✅ **Day Selection List** (shows all days between start and end)
- ✅ Quick "Select All" and "Clear All" buttons

## User Flow

### Single-Day Festival
1. Select the same date for both start and end
2. That day is automatically selected
3. No day selection list is shown

### Multi-Day Festival
1. Select festival start date
2. Select festival end date (can be same or later)
3. A list of all days appears with checkboxes
4. User selects which days they attended
5. Quick actions available:
   - "Select All" - checks all days
   - "Clear All" - unchecks all days

## Technical Implementation

### State Variables (Changed)
```swift
// Removed:
@State private var hasEndDate = false
@State private var endDate = Date()
@State private var useSpecificDates = false
@State private var specificDates: [Date] = []

// Added:
@State private var festivalStartDate = Date()
@State private var festivalEndDate = Date()
@State private var selectedAttendedDays: Set<Date> = []
```

### New Helper Functions
- `festivalDaysInRange` - Computed property that generates all dates between start and end
- `updateSelectedDaysForDateRange()` - Auto-updates selections when date range changes
- `toggleDaySelection()` - Handles individual day selection
- `formatDayForSelection()` - Formats dates as "Friday, August 10"

### Validation
The form is only valid when:
- Festival name is not empty
- At least one artist is added
- **At least one day is selected** (new requirement)

### Data Storage
- Festival start date is stored in `Concert.date`
- Last attended date is stored in `Concert.endDate`
- All attended dates are stored as ISO8601 strings in `Concert.attendedDates` (comma-separated)

## Benefits

1. **More Intuitive** - Users think about festivals in terms of "it runs from X to Y"
2. **Clearer Selection** - Visual list makes it obvious which days were attended
3. **Flexible** - Works equally well for consecutive and non-consecutive attendance
4. **Less Cluttered** - Removed confusing toggle switches
5. **Better Validation** - Impossible to save a festival without selecting attended days

## Edge Cases Handled

1. **Changing date range after selection** - Previously selected days outside the new range are automatically deselected
2. **Single-day festivals** - All days (just one) are auto-selected, no selection UI shown
3. **Legacy data migration** - Old festivals using the previous system are converted on load
4. **Date range validation** - End date can't be before start date (enforced by DatePicker)

## Example Scenarios

### Scenario 1: Attended all days
1. Set start: August 10, 2026
2. Set end: August 14, 2026
3. Click "Select All"
4. Save

Result: Festival attended August 10-14

### Scenario 2: Attended specific days
1. Set start: August 10, 2026
2. Set end: August 14, 2026
3. Select Friday, Sunday, and Monday
4. Save

Result: Festival attended August 10, 12, 13

### Scenario 3: Single day
1. Set start: August 10, 2026
2. Set end: August 10, 2026
3. Day is auto-selected
4. Save

Result: Festival attended August 10
