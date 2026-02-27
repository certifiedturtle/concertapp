# Photo Loading Debug Guide

## What I Just Fixed

### Issue: Photos weren't saving
**Root Cause**: The `ConcertDetailView` was creating its own `ConcertViewModel` instance with a separate Core Data context, so saves weren't persisting to the main context.

### Solution Applied:
1. ✅ Removed the separate `viewModel` instance
2. ✅ Now using the environment's `viewContext` directly
3. ✅ Added comprehensive logging to track the entire flow
4. ✅ Added proper error handling and alerts
5. ✅ Fixed async/await context switching
6. ✅ Added forced view refresh after saving

## How to Test & Debug

### Step 1: Check Console Logs
When you select a photo, you should see detailed logs like:

```
🎬 Starting to load 1 photo(s)...
📸 Processing photo 1 of 1
🔍 Attempting to load photo 0...
   Item identifier: 12345ABC-6789-DEF0-1234-56789ABCDEF0
   Supported types: ["public.image"]
   Trying direct identifier lookup: 12345ABC-6789-DEF0-1234-56789ABCDEF0
✅ Found asset 0 using itemIdentifier: 12345ABC-6789-DEF0-1234-56789ABCDEF0
   Asset type: image
   Dimensions: 4032 x 3024
✅ Added photo 1: 12345ABC-6789-DEF0-1234-56789ABCDEF0
💾 Saved photo to Core Data

✨ Finished: 1 added, 0 failed
```

### Step 2: What to Look For in Logs

#### ✅ Good Signs:
- `Found asset using itemIdentifier` - The easy path worked
- `Added photo X: [identifier]` - Photo was added to Core Data
- `💾 Saved photo to Core Data` - Changes were saved
- `Finished: 1 added, 0 failed` - Success!

#### ⚠️ Warning Signs:
- `Item has no identifier` - PhotosPicker didn't provide identifier
- `No asset found with identifier` - Identifier lookup failed, will try fallback
- `Trying fallback method` - Had to use dimension matching
- `Photo already exists, skipping` - Duplicate prevention working

#### ❌ Error Signs:
- `Could not load image data` - Can't read the photo data
- `Could not create UIImage from data` - Data is corrupted
- `Could not find matching asset` - Neither method worked
- `Error saving photo` - Core Data save failed
- `Finished: 0 added, 1 failed` - Complete failure

### Step 3: Common Issues & Solutions

#### Problem: "Item has no identifier"
**Cause**: PhotosPicker couldn't get the asset ID directly  
**Solution**: The code falls back to dimension matching automatically  
**Check**: Look for "Trying fallback method" in console  

#### Problem: "No asset found with identifier"
**Cause**: The identifier format doesn't match PHAsset format  
**Solution**: Same as above, automatic fallback  
**Action**: This is expected for some photos, especially iCloud photos  

#### Problem: "Could not find matching asset"
**Cause**: 
- Photo might be in iCloud and not downloaded
- Photo might be from a shared album
- Photo might be a screenshot or edited version

**Solutions**:
1. Make sure iCloud Photos is synced
2. Try a photo taken directly with the camera
3. Check photo library permissions (Settings → [App Name] → Photos)

#### Problem: Photo saves but doesn't appear
**Cause**: View not refreshing  
**Check**: 
```swift
// In ConcertDetailView, the concert.photosArray should update automatically
// Check if this line exists and is working:
PhotoGridView(photos: concert.photosArray, onTap: { photo in
```

**Solution**: The code now calls `viewContext.refreshAllObjects()` to force refresh

#### Problem: "Error saving photo"
**Cause**: Core Data context issue  
**Solutions**:
1. Check if the app has Core Data access
2. Run Diagnostics (Settings → Diagnostics & Data Tools)
3. Look for specific error message in console

### Step 4: Manual Verification

After selecting a photo:

1. **Check Console** - Look for success messages
2. **Check Diagnostics** - Go to Settings → Diagnostics, tap "Refresh Stats"
   - Photo count should increase
3. **Navigate Away** - Go back to concerts list, then back to detail
   - Photo should still be there (proves it saved)
4. **Restart App** - Force quit and relaunch
   - Photo should persist

### Step 5: Testing Permissions

If photos aren't loading at all:

1. Go to iOS Settings → [Your App Name] → Photos
2. Should be set to "All Photos" or "Selected Photos"
3. If set to "None", photos won't load
4. Try revoking and re-granting permission

### Step 6: Fallback Method Details

If `itemIdentifier` fails, the code:
1. Loads the photo data
2. Creates a UIImage to get dimensions
3. Searches through your photo library
4. Finds photos with matching dimensions
5. Returns the most recent match

**Limitations**:
- Multiple photos with same dimensions might match wrong photo
- Very slow for large libraries (1000+ photos)
- Doesn't work for photos outside library

## Advanced Debugging

### Enable Detailed Core Data Logging

Add to your scheme's launch arguments:
```
-com.apple.CoreData.SQLDebug 1
```

### Check Photo Count Programmatically

Add this temporary button to test:
```swift
Button("Debug: Check Photos") {
    print("Concert has \(concert.photosArray.count) photos")
    for photo in concert.photosArray {
        print("  - \(photo.wrappedPhotoIdentifier)")
    }
}
```

### Force Core Data Save

If you suspect saves aren't happening:
```swift
try? viewContext.save()
print("Context has changes: \(viewContext.hasChanges)")
```

## What You Should Try Now

1. **Select a recent camera photo** (not screenshot, not edited)
2. **Watch the console carefully** - Share the log output
3. **Check Settings → Diagnostics** - Verify photo count increases
4. **Navigate away and back** - Confirm persistence

## Expected Behavior

When everything works:
1. Tap "Add" button ✅
2. Photos picker opens ✅
3. Select 1-3 photos ✅
4. Tap "Add" in picker ✅
5. Console shows processing logs ✅
6. Photos appear in grid immediately ✅
7. Navigate away and back - photos still there ✅
8. Restart app - photos still there ✅

## If Still Not Working

Share these details:
1. Complete console output from photo selection
2. Screenshot of Diagnostics screen showing counts
3. iOS version and device type
4. Photo library permission status
5. Whether you're using iCloud Photos
