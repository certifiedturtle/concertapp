# ADD dateGranularity TO CORE DATA MODEL

## The Error You're Seeing

```
-[Concert dateGranularity]: unrecognized selector sent to instance
```

This means the Core Data model file doesn't have the `dateGranularity` attribute yet.

## Quick Fix Steps

### 1. Open Core Data Model Editor
- In Xcode Project Navigator (left sidebar)
- Look for a file ending in `.xcdatamodeld`
- Should be named `ConcertApp.xcdatamodeld` or similar
- **Click on it** to open the visual model editor

### 2. Select Concert Entity
- In the ENTITIES section (left panel)
- Click on **Concert**

### 3. Add the Attribute
- Look at the ATTRIBUTES section (middle panel)
- Click the **"+"** button at the bottom
- A new row will appear

### 4. Configure the New Attribute
Set these values:

| Property | Value |
|----------|-------|
| **Attribute Name** | `dateGranularity` |
| **Type** | `String` (choose from dropdown) |
| **Optional** | ✅ **CHECKED** (must be optional) |
| **Default Value** | (leave empty) |

### 5. Save and Rebuild
1. Save the model: `Cmd+S`
2. Clean Build Folder: `Product → Clean Build Folder` or `Cmd+Shift+K`
3. Build: `Cmd+B`
4. Run: `Cmd+R`

---

## Updated Core Data Model Definition

Your Concert entity should now have these attributes:

```
ENTITY: Concert
Attributes:
  - id: UUID
  - date: Date (Optional)
  - dateGranularity: String (Optional) ← NEW!
  - venueName: String (Optional)
  - city: String (Optional)
  - state: String (Optional)
  - concertDescription: String (Optional)
  - setlistURL: String (Optional)
  - concertType: String (Optional)
  - friendsTags: String (Optional)

Relationships:
  - artists: To-Many → Artist, Delete Rule: Cascade
  - photos: To-Many → ConcertPhoto, Delete Rule: Cascade
```

---

## If You Still Get Errors

### Option A: Lightweight Migration
If you have existing data and get migration errors, add this to `PersistenceController.swift`:

```swift
container.persistentStoreDescriptions.first?.setOption(true as NSNumber, 
    forKey: NSPersistentStoreAutomaticMigrationOption)
container.persistentStoreDescriptions.first?.setOption(true as NSNumber, 
    forKey: NSInferMappingModelAutomaticallyOption)
```

### Option B: Reset Simulator Data
If this is just testing and you don't need existing data:

1. In Simulator: **Device → Erase All Content and Settings**
2. Or in Xcode: **Product → Clean Build Folder** then rebuild

### Option C: Delete App from Simulator
1. Long-press app icon in simulator
2. Tap the X to delete
3. Rebuild and run

---

## Visual Reference

**Before (Missing dateGranularity):**
```
Concert Entity
├── id: UUID
├── date: Date
├── venueName: String
├── city: String
└── ... (other attributes)
```

**After (With dateGranularity):**
```
Concert Entity
├── id: UUID
├── date: Date
├── dateGranularity: String ← ADD THIS!
├── venueName: String
├── city: String
└── ... (other attributes)
```

---

## Verification

After adding the attribute, you should see it in the model editor:

```
┌─────────────────────────────────────┐
│ ATTRIBUTES                          │
├─────────────────────────────────────┤
│ ☑ id                    UUID        │
│ ☑ date                  Date        │
│ ☑ dateGranularity       String  ← ✅│
│ ☑ venueName             String      │
│ ☑ city                  String      │
│ ...                                 │
└─────────────────────────────────────┘
```

---

## Still Having Trouble?

If you can't find the `.xcdatamodeld` file:

1. Use Xcode's search: Press `Cmd+Shift+O`
2. Type: `xcdatamodeld`
3. Select the file that appears

Or use the file navigator filter:
1. Click the filter at bottom of Project Navigator
2. Type: `.xcdatamodeld`

---

## Why This Happened

The Swift property was added to `Concert+CoreDataProperties.swift`, but Core Data needs the attribute defined in the **visual model file** first. Core Data generates the actual storage based on the model file, not the Swift code.

**The flow is:**
1. Define attribute in `.xcdatamodeld` (visual model editor) ✅ DO THIS
2. Swift properties in `+CoreDataProperties.swift` match the model
3. Core Data creates database schema from model
4. App runs successfully

---

Once you add the attribute to the model file and rebuild, the error should disappear! 🎉
