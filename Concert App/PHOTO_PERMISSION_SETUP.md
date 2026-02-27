# Photo Library Permission Setup

## Required Info.plist Entries

To enable photo access in your Concert App, you need to add privacy descriptions to your `Info.plist` file.

### Steps to Add Privacy Permissions:

1. **Open your project in Xcode**

2. **Find Info.plist**:
   - In the Project Navigator, look for `Info.plist` (it might be inside the app folder)
   - Alternatively, select your app target → Info tab

3. **Add these keys**:

   Right-click in the Info.plist and select "Add Row", then add these entries:

   | Key | Type | Value |
   |-----|------|-------|
   | `Privacy - Photo Library Additions Usage Description` | String | `We need access to save photos to your concerts` |
   | `NSPhotoLibraryAddUsageDescription` | String | `We need access to save photos to your concerts` |

   **Optional** (if you want to read existing photos):
   | Key | Type | Value |
   |-----|------|-------|
   | `Privacy - Photo Library Usage Description` | String | `We need access to attach photos from your library to concerts` |
   | `NSPhotoLibraryUsageDescription` | String | `We need access to attach photos from your library to concerts` |

### Raw XML (Alternative Method)

If you prefer to edit the Info.plist as source code, add these lines inside the `<dict>` tag:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save photos to your concerts</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to attach photos from your library to concerts</string>
```

### What the Code Now Does:

✅ **First Time**: When a user taps "Add" to add photos, the app will show iOS's standard permission prompt with your custom message

✅ **Permission Granted**: Opens the PhotosPicker immediately

✅ **Permission Denied**: Shows a helpful alert with a button to open Settings

✅ **Already Authorized**: Opens PhotosPicker without any delay

### Testing:

1. Add the Info.plist entries
2. Build and run the app
3. Navigate to a concert detail view
4. Tap the "Add" button under Photos & Videos
5. You should see the system permission prompt (first time) or the photo picker (if already granted)

### Reset Permissions for Testing:

To test the permission flow again:
- Settings → General → Transfer or Reset iPhone → Reset → Reset Location & Privacy
- Or: Delete the app and reinstall it

---

## Troubleshooting

**"Photo library access not authorized" error**:
- Make sure you've added the Info.plist entries
- Check Settings → Privacy & Security → Photos → Concert App
- The app needs at least "Add Photos Only" or "Full Access"

**Photos not showing after selection**:
- Make sure the photos are being saved (check console logs)
- Try pulling down to refresh the view
- Check that Core Data is saving properly
