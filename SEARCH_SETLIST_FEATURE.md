# Search for Setlist Feature - Implementation Complete ✅

## Overview
Added the ability to search for concert setlists directly from the app. When a concert doesn't have a setlist URL, users can tap "Search for Setlist" to open Safari with a pre-formatted Google search using the concert's details.

## Feature Behavior

### Where It Appears
The "Search for Setlist" button appears in **two places**:

1. **Concert Detail View**: Shows instead of "View Setlist" link when URL is empty
2. **Add/Edit Concert View**: Shows below the Setlist URL field when it's empty

### When It Shows
- ✅ Setlist URL is empty or nil
- ✅ User has entered concert data (artist, venue, date)

### When It Hides
- ❌ Setlist URL has been filled in
- ✅ "View Setlist" link appears instead

## Search Query Format

The search query is built using this format:
```
setlistfm [artist] [venue] [city, state] [date]
```

### Example Queries

**Full data available:**
```
setlistfm Taylor Swift Madison Square Garden New York, NY February 27, 2026
```

**Without city/state (optional fields):**
```
setlistfm The Beatles Red Rocks Amphitheatre June 15, 2026
```

**Minimal data:**
```
setlistfm Unknown Artist Unknown Venue February 27, 2026
```

### Query Components

| Component | Source | Required | Fallback |
|-----------|--------|----------|----------|
| Prefix | Static | Yes | "setlistfm" |
| Artist | Primary artist name | Yes | "Unknown Artist" |
| Venue | Venue name | Yes | "Unknown Venue" |
| City | City field | No | Omitted if empty |
| State | State field | No | Omitted if empty |
| Date | Concert date | Yes | Current date from picker |

### Artist Selection Logic
1. First, look for headliner artist (marked as headliner)
2. If no headliner, use first artist in list
3. If no artists entered, use "Unknown Artist"

### Date Format
- **Style**: Full date format
- **Example**: "February 27, 2026"
- **Locale**: User's device locale

## User Flow

### From Concert Detail View
1. User views concert without setlist URL
2. Sees "Search for Setlist" button with magnifying glass and Safari icons
3. Taps button → Safari opens with Google search
4. User finds setlist, copies URL
5. Returns to app (iOS multitasking)
6. Taps Edit button
7. Pastes URL into Setlist URL field
8. Saves
9. "Search for Setlist" button replaced with "View Setlist" link

### From Edit View
1. User creates/edits concert
2. Fills in artist, venue, date
3. Leaves Setlist URL field empty
4. Sees "Search for Setlist" button below URL field
5. Taps button → Safari opens with search
6. User finds setlist, copies URL
7. Returns to app (iOS multitasking back to form)
8. Pastes URL into field
9. Button disappears (URL is no longer empty)
10. Saves concert

## Implementation Details

### Files Modified

#### 1. ConcertDetailView.swift

**New Function:**
```swift
private func searchForSetlist() {
    // Build search query: "setlistfm [artist] [venue] [city, state] [date]"
    let artist = concert.primaryArtistName
    let venue = concert.wrappedVenueName
    let city = concert.wrappedCity
    let state = concert.wrappedState
    
    // Format date as full date (e.g., "February 27, 2026")
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    let dateString = dateFormatter.string(from: concert.wrappedDate)
    
    // Build query components
    var queryComponents = ["setlistfm", artist, venue]
    
    // Add city and state if available
    if !city.isEmpty && !state.isEmpty {
        queryComponents.append("\(city), \(state)")
    } else if !city.isEmpty {
        queryComponents.append(city)
    }
    
    queryComponents.append(dateString)
    
    let query = queryComponents.joined(separator: " ")
    
    // URL encode and open Safari with Google search
    if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
       let url = URL(string: "https://www.google.com/search?q=\(encodedQuery)") {
        UIApplication.shared.open(url)
        print("🔍 Searching for setlist: \(query)")
    }
}
```

**Updated UI:**
```swift
// Setlist URL
if let setlistURL = concert.setlistURL, !setlistURL.isEmpty, let url = URL(string: setlistURL) {
    // Show link when URL exists
    Link(destination: url) { ... }
} else {
    // Show search button when URL is empty
    Button { searchForSetlist() } label: {
        HStack {
            Label("Search for Setlist", systemImage: "magnifyingglass")
            Spacer()
            Image(systemName: "safari")
        }
    }
}
```

#### 2. AddEditConcertView.swift

**New Function:**
```swift
private func searchForSetlist() {
    // Get primary artist (first headliner or first artist)
    let primaryArtist: String
    if let headliner = artists.first(where: { $0.isHeadliner && !$0.name.isEmpty }) {
        primaryArtist = headliner.name
    } else if let firstArtist = artists.first(where: { !$0.name.isEmpty }) {
        primaryArtist = firstArtist.name
    } else {
        primaryArtist = "Unknown Artist"
    }
    
    let venue = venueName.isEmpty ? "Unknown Venue" : venueName
    
    // Format date and build query
    // ... (similar to ConcertDetailView)
}
```

**Updated UI:**
```swift
Section("Additional Info") {
    VStack(alignment: .leading, spacing: 8) {
        TextField("Setlist URL", text: $setlistURL)
        
        // Show search button if setlist URL is empty
        if setlistURL.isEmpty {
            Button { searchForSetlist() } label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Search for Setlist")
                    Spacer()
                    Image(systemName: "safari")
                }
            }
        }
    }
    // ... other fields
}
```

## Visual Design

### Concert Detail View Button
```
┌─────────────────────────────────────┐
│ 🔍 Search for Setlist        🧭     │
└─────────────────────────────────────┘
```
- **Icon**: Magnifying glass (left)
- **Text**: "Search for Setlist"
- **Icon**: Safari compass (right)
- **Style**: Blue, headline font
- **Layout**: Full width, like Link style

### Edit View Button
```
┌─────────────────────────────────────┐
│ Setlist URL                         │
│ [                                 ] │
│ 🔍 Search for Setlist        🧭     │
└─────────────────────────────────────┘
```
- **Icon**: Magnifying glass (left)
- **Text**: "Search for Setlist"
- **Icon**: Safari compass (right)
- **Style**: Blue, subheadline font
- **Layout**: Below text field, indented

## Console Output

**Successful search:**
```
🔍 Searching for setlist: setlistfm Taylor Swift Madison Square Garden New York, NY February 27, 2026
```

**Error (rare):**
```
❌ Could not create search URL
```

## Edge Cases Handled

| Scenario | Behavior |
|----------|----------|
| Empty artist name | Uses "Unknown Artist" |
| Empty venue name | Uses "Unknown Venue" |
| Missing city | Omits city from search |
| Missing state | Omits state from search |
| Missing both city/state | Just artist, venue, date |
| Special characters in names | URL encoded automatically |
| Multiple artists | Uses headliner or first artist |
| Festival | Uses primary artist (same logic) |
| User adds then deletes URL | Button reappears |
| User types then clears URL | Button reappears |

## URL Encoding

Special characters are automatically encoded:
- Spaces → `%20` or `+`
- Ampersands → `%26`
- Quotes → `%22`
- etc.

Example:
```
Input:  "The Beatles & Wings"
Output: "The%20Beatles%20%26%20Wings"
```

## Benefits

### User Experience
✅ **Fast**: One tap to search  
✅ **Contextual**: Uses their concert data  
✅ **Flexible**: Can choose any setlist site  
✅ **Seamless**: iOS multitasking for easy return  
✅ **Smart**: Only shows when needed  

### Search Quality
✅ **Specific**: Includes venue and date for accuracy  
✅ **Flexible**: Optional city/state for variable data  
✅ **Targeted**: "setlistfm" prefix guides results  
✅ **Natural**: Full date format improves matching  

## Future Enhancements

Potential improvements for later:

1. **Multiple Setlist Sites**
   - Option to search setlist.fm directly
   - Option for Songkick, Live Nation, etc.
   - User preference for default search

2. **Multiple Artists**
   - For festivals, allow searching for each artist
   - Picker to choose which artist to search

3. **Smart Paste Detection**
   - Auto-detect when user copies a URL
   - Offer to paste it automatically

4. **In-App Browser**
   - Use SFSafariViewController instead of external Safari
   - Stay in-app for smoother experience

5. **Setlist API Integration**
   - Direct integration with setlist.fm API
   - Auto-populate setlist without copying URL
   - Show preview of setlist in app

## Testing Checklist

- [x] Button appears in detail view when URL empty
- [x] Button appears in edit view when URL empty
- [x] Button opens Safari with correct search
- [x] Search includes artist, venue, date
- [x] Search includes city/state if available
- [x] Search works without city/state
- [x] Button disappears when URL added
- [x] Button reappears when URL deleted
- [x] Works with festivals (primary artist)
- [x] Works with multiple artists (headliner)
- [x] Handles special characters correctly
- [x] Console logs show search query
- [x] Can return to app from Safari
- [x] Can paste URL after searching

## Example Test Scenarios

### Scenario 1: Complete Concert Data
**Input:**
- Artist: Taylor Swift
- Venue: Madison Square Garden
- City: New York
- State: NY
- Date: Feb 27, 2026

**Search Query:**
```
setlistfm Taylor Swift Madison Square Garden New York, NY February 27, 2026
```

### Scenario 2: Minimal Data
**Input:**
- Artist: The Beatles
- Venue: Red Rocks
- City: (empty)
- State: (empty)
- Date: Jun 15, 2026

**Search Query:**
```
setlistfm The Beatles Red Rocks June 15, 2026
```

### Scenario 3: Festival with Multiple Artists
**Input:**
- Artists: Headliner: Coachella, Others: Various
- Venue: Empire Polo Club
- City: Indio
- State: CA
- Date: Apr 12, 2026

**Search Query:**
```
setlistfm Coachella Empire Polo Club Indio, CA April 12, 2026
```

## Success Metrics

What defines success:
- ✅ Users can find setlists quickly
- ✅ Search results are relevant
- ✅ Workflow is smooth and intuitive
- ✅ Button visibility is clear
- ✅ No confusion about when to use it

---

**Implementation Complete!** The feature is ready to use in both the concert detail view and the edit form. 🎉
