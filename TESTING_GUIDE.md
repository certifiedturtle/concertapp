# Testing Guide - Photo Grid Bug Fixes

## Overview
This guide helps you test the recent bug fixes for the photo grid display and multiple photo upload issues.

## How to Clear Data for Testing

### Method 1: Using the Diagnostics UI (Recommended)
1. Launch the app
2. Navigate to the **Settings** tab
3. Tap **Diagnostics & Data Tools**
4. You'll see:
   - **Database Statistics**: Shows current counts of concerts, artists, and photos
   - **Clear All Photos**: Removes only photo references (concerts remain)
   - **Clear All Data**: Removes everything (concerts, artists, and photos)

### Method 2: Programmatically (Advanced)
You can call these methods directly in code:

```swift
// Clear only photos
try PersistenceController.shared.clearAllPhotos()

// Clear all data
try PersistenceController.shared.clearAllData()

// Get current statistics
let stats = PersistenceController.shared.getDataStats()
print("Concerts: \(stats.concerts), Artists: \(stats.artists), Photos: \(stats.photos)")
```

## End-to-End Testing Steps

### Test 1: Photo Grid Display Fix
**What was fixed**: Photos now display in a uniform grid without overlapping

1. Clear all data using the Diagnostics view
2. Create a new concert
3. Add 6-9 photos to the concert
4. Verify:
   - ✅ Photos appear in a uniform grid
   - ✅ All photos are square and the same size
   - ✅ No photos overlap each other
   - ✅ Grid items are properly aligned
   - ✅ Spacing between photos is consistent (4pt)

### Test 2: Multiple Photo Upload Fix
**What was fixed**: All selected photos are now added (not just the first one)

1. Clear all data or create a new concert
2. Tap "Add Photos"
3. Select **5 different photos** from your library
4. Wait for them to load
5. Verify:
   - ✅ All 5 photos appear in the grid
   - ✅ Photos are the ones you selected (not duplicates)
   - ✅ Check console logs show: "Added photo 1", "Added photo 2", etc.
   - ✅ No duplicate photos

### Test 3: Adding Photos to Existing Concert
1. Create a concert with 2 photos
2. View the concert detail
3. Add 3 more photos
4. Verify:
   - ✅ Now shows 5 photos total
   - ✅ New photos appear at the beginning (most recent first)
   - ✅ Original 2 photos still visible

### Test 4: Video Support
1. Create a concert
2. Add a mix of photos and videos
3. Verify:
   - ✅ Videos show play button overlay
   - ✅ Videos display in grid like photos
   - ✅ Can tap videos to view full screen

### Test 5: Full-Screen Gallery
1. Create a concert with multiple photos
2. Tap any photo to open full screen
3. Verify:
   - ✅ Swipe left/right to navigate photos
   - ✅ Photo counter shows (e.g., "3 / 7")
   - ✅ Can zoom photos with pinch gesture
   - ✅ Double-tap to reset zoom
   - ✅ X button closes gallery

## Expected Console Output

When adding photos, you should see logs like:
```
📸 Processing photo 1 of 3
✅ Found asset using itemIdentifier: ABC123-DEF456...
✅ Added photo 1: ABC123-DEF456...
📸 Processing photo 2 of 3
✅ Found asset using itemIdentifier: XYZ789-GHI012...
✅ Added photo 2: XYZ789-GHI012...
```

## Common Issues & Solutions

### Issue: Photos not loading
- Check photo library permissions in Settings → [App Name]
- Try running the diagnostic test
- Check console for error messages

### Issue: Wrong photos appear
- The fallback matching uses pixel dimensions
- Make sure photos have unique dimensions
- itemIdentifier should work in most cases

### Issue: Duplicate photos
- The code now checks for duplicates before adding
- If you see duplicates, check the console logs

## Data Management

### What Gets Cleared:
- **Clear All Photos**: Removes photo references from Core Data (your actual photos in Photos app are safe)
- **Clear All Data**: Removes concerts, artists, and photo references (your Photos app is still safe)

### What Doesn't Get Cleared:
- Your actual photos in the iOS Photos library
- App settings (sort order, preferences)
- Photo library permissions

## Technical Details

### Grid Configuration:
- Minimum size: 100pt
- Maximum size: 150pt
- Spacing: 4pt
- Aspect ratio: 1:1 (square)

### Photo Matching Strategy:
1. First try: Direct itemIdentifier lookup (most reliable)
2. Fallback: Match by pixel dimensions and metadata
3. Duplicate prevention by checking existing identifiers

## Testing Checklist

- [ ] Clear all data successfully
- [ ] Create concert with single photo
- [ ] Create concert with multiple photos (5+)
- [ ] Add photos to existing concert
- [ ] Verify grid layout is uniform
- [ ] Verify all selected photos appear
- [ ] Test full-screen photo viewer
- [ ] Test video upload and display
- [ ] Test swipe navigation in gallery
- [ ] Verify photo counter works
- [ ] Test zoom gestures
- [ ] Check console logs for errors

## Need Help?

Check these files for more information:
- `DEBUG_GUIDE.md` - General debugging help
- `PHOTO_PERMISSION_SETUP.md` - Photo permissions
- `DiagnosticView.swift` - Diagnostic tools code
- `PersistenceController.swift` - Data management code
