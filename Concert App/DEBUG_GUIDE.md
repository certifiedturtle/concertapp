# 🔧 Debug Checklist for Concert App

## Common Issues & Solutions:

### Issue 1: Core Data Model File Name Mismatch
**Problem**: The code expects a model named "ConcertApp" but your file might be named differently.

**Check**:
- In Xcode Project Navigator, look for a file ending in `.xcdatamodeld`
- The file should be named **exactly** `ConcertApp.xcdatamodeld`
- If it's named differently (like `Concert_App.xcdatamodeld` or `ConcertModel.xcdatamodeld`), you need to either:
  - **Option A**: Rename the file to `ConcertApp.xcdatamodeld`
  - **Option B**: Update `PersistenceController.swift` line 16 to match your file name

### Issue 2: Entity Names Must Match Exactly
**Check in your .xcdatamodeld file**:
- Entity names must be EXACTLY: `Concert`, `Artist`, `ConcertPhoto` (case-sensitive)
- Class names in Data Model Inspector should match these names

### Issue 3: Codegen Setting
**Check**:
- Select each entity in your .xcdatamodeld file
- Open Data Model Inspector (right panel)
- **Codegen MUST be set to "Manual/None"** for all three entities
- If it's set to "Class Definition" or "Category/Extension", the code will conflict

### Issue 4: Missing Attributes or Wrong Types
**Verify each entity has ALL these attributes with correct types**:

**Concert Entity**:
- ✓ id (UUID)
- ✓ date (Date)
- ✓ venueName (String, Optional)
- ✓ city (String, Optional)
- ✓ state (String, Optional)
- ✓ concertDescription (String, Optional)
- ✓ setlistURL (String, Optional)
- ✓ concertType (String, Optional)
- ✓ friendsTags (String, Optional)

**Artist Entity**:
- ✓ id (UUID)
- ✓ name (String, Optional)
- ✓ isHeadliner (Boolean, default NO)

**ConcertPhoto Entity**:
- ✓ id (UUID)
- ✓ photoIdentifier (String, Optional)
- ✓ dateAdded (Date, Optional)
- ✓ isVideo (Boolean, default NO)

### Issue 5: Missing or Incorrect Relationships
**Concert Entity Relationships**:
- ✓ artists (To-Many, Destination: Artist, Delete Rule: Cascade, Inverse: concert)
- ✓ photos (To-Many, Destination: ConcertPhoto, Delete Rule: Cascade, Inverse: concert)

**Artist Entity Relationships**:
- ✓ concert (To-One, Destination: Concert, Delete Rule: Nullify, Inverse: artists)

**ConcertPhoto Entity Relationships**:
- ✓ concert (To-One, Destination: Concert, Delete Rule: Nullify, Inverse: photos)

### Issue 6: Build Errors
**If you see build errors**:
1. Clean Build Folder: `Product > Clean Build Folder` (⇧⌘K)
2. Delete Derived Data:
   - `Window > Devices and Simulators > Simulators`
   - Right-click your app and delete
   - Or manually: `~/Library/Developer/Xcode/DerivedData`
3. Restart Xcode
4. Build again: `⌘B`

### Issue 7: Preview Not Loading
**If canvas shows "Preview Not Available"**:
1. Check the diagnostics in the preview pane (click the yellow warning icon)
2. Make sure you're running on a compatible simulator
3. Try: `Editor > Canvas > Refresh Canvas`
4. Or press: `⌥⌘P`

### Issue 8: Simulator Crash on Launch
**If app crashes immediately**:
1. Check Console output in Xcode (⇧⌘C)
2. Look for error messages mentioning:
   - "Could not find model named 'ConcertApp'"
   - "Entity description not found"
   - "No NSEntityDescription found"
3. These all point to Core Data model issues (see Issue 1-5 above)

## 🧪 Quick Test Steps:

1. **Open `PersistenceController.swift`**
   - Find line 16: `container = NSPersistentContainer(name: "ConcertApp")`
   - Make sure "ConcertApp" matches your .xcdatamodeld file name (without extension)

2. **Verify Core Data Model File Exists**:
   - Press `⌘1` to open Project Navigator
   - Search for `.xcdatamodeld`
   - Click on it - you should see three entities on the left: Concert, Artist, ConcertPhoto

3. **Test Simple Preview First**:
   - Open `SettingsView.swift` (this doesn't use Core Data)
   - Try to preview this first
   - If this works, the issue is definitely Core Data related

4. **Check Build Output**:
   - Build the project (`⌘B`)
   - Check for any errors in the Issue Navigator (`⌘4`)
   - Red errors = must fix before running
   - Yellow warnings = okay to ignore for now

## 📝 What to Report Back:

Please check the above and let me know:
1. What is the EXACT name of your .xcdatamodeld file?
2. What error messages do you see? (copy/paste from Xcode)
3. Does the SettingsView preview work?
4. Any red build errors in Issue Navigator?

This will help me pinpoint the exact issue! 🎯
