# 🚀 Quick Start Guide - Get Your App Running

## ✅ Fixes Applied:

I've just fixed several issues that were preventing previews and simulators from running:

1. **Added missing CoreData imports** to all view files
2. **Added missing Combine import** to ViewModels (needed for @Published)
3. **Fixed managed object context passing** in sheet presentations
4. **Made empty state iOS 16+ compatible** (removed ContentUnavailableView dependency)

## 🧪 Test Your Setup - 3 Steps:

### Step 1: Run the Diagnostic Tool
1. Open **`DiagnosticView.swift`** in Xcode
2. Click **Resume** in the preview canvas
3. You should see either:
   - ✅ Green checkmark = Core Data is working perfectly!
   - ❌ Red triangle = There's a Core Data configuration issue

If you see red, the error message will tell you exactly what's wrong.

### Step 2: Verify Core Data Model Name
1. In Xcode Project Navigator (⌘1), find your `.xcdatamodeld` file
2. **The file MUST be named exactly: `ConcertApp.xcdatamodeld`**
3. If it's named differently:
   - Right-click the file → Rename → Name it `ConcertApp`
   - OR update line 16 in `PersistenceController.swift` to match your file name

### Step 3: Try Previews in This Order

**Test A - Simple View (No Core Data)**
- Open `SettingsView.swift`
- Click Resume in canvas
- Should preview immediately without issues

**Test B - Diagnostic View (Tests Core Data)**
- Open `DiagnosticView.swift`  
- Click Resume in canvas
- Check for green checkmark

**Test C - Main App**
- Open `MainTabView.swift`
- Click Resume in canvas
- You should see the full app with tabs!

## 🏃‍♂️ Running on Simulator:

1. Select a simulator from the scheme menu (top of Xcode)
2. Press `⌘R` to build and run
3. App should launch and show the Concerts tab

**If it crashes on launch:**
- Check the Console (⇧⌘C) for error messages
- Most common issue: Core Data model file name mismatch
- Solution: See "Step 2" above

## 📋 Pre-Flight Checklist:

Before running, verify these in your .xcdatamodeld file:

### Entities (must have all 3):
- [ ] Concert
- [ ] Artist  
- [ ] ConcertPhoto

### For EACH entity, check Codegen setting:
- [ ] Concert → Codegen = "Manual/None"
- [ ] Artist → Codegen = "Manual/None"
- [ ] ConcertPhoto → Codegen = "Manual/None"

**Why Manual/None?** Because we've already created the Swift classes. If Xcode also generates them, you'll get duplicate symbol errors.

### Concert Entity Checklist:
- [ ] Has relationship: artists (To-Many → Artist)
- [ ] Has relationship: photos (To-Many → ConcertPhoto)
- [ ] Both relationships have Delete Rule = Cascade
- [ ] Inverse relationships are set correctly

### Artist Entity Checklist:
- [ ] Has attribute: isHeadliner (Boolean, NOT optional)
- [ ] Has relationship: concert (To-One → Concert)
- [ ] Relationship has Delete Rule = Nullify
- [ ] Inverse relationship = Concert.artists

### ConcertPhoto Entity Checklist:
- [ ] Has attribute: isVideo (Boolean, NOT optional)
- [ ] Has relationship: concert (To-One → Concert)
- [ ] Relationship has Delete Rule = Nullify
- [ ] Inverse relationship = Concert.photos

## 🔍 Still Having Issues?

### Get More Details:
1. Build the project: `⌘B`
2. Check Issue Navigator: `⌘4`
3. Look for red error messages

### Common Error Messages and Solutions:

**"Could not find model named 'ConcertApp'"**
→ Your .xcdatamodeld file is named differently. Rename it or update PersistenceController.swift

**"No NSEntityDescription found for entity 'Concert'"**
→ Entity name in .xcdatamodeld doesn't match code. Must be exactly "Concert" (case-sensitive)

**"Duplicate interface definition for class 'Concert'"**
→ Codegen is NOT set to Manual/None. Change it in Data Model Inspector

**"Property 'viewContext' is not available"**
→ Missing CoreData import. Add `import CoreData` at top of file

**"Type 'ConcertViewModel' does not conform to protocol 'ObservableObject'"**
→ Missing Combine import. Add `import Combine` to ViewModel files (already fixed!)

## 📞 Report Back:

If you're still having issues, please tell me:

1. **What's the exact name of your .xcdatamodeld file?**
   - Find it in Project Navigator and tell me the full name

2. **What happens when you run DiagnosticView?**
   - Green checkmark? Red error? Copy the full message

3. **Any build errors?**
   - Open Issue Navigator (⌘4) and copy any red errors

4. **What iOS deployment target is set?**
   - Select project in Navigator → Check "Minimum Deployments" under General tab
   - Should be iOS 16.0 or higher

This will help me solve the exact issue! 💪
