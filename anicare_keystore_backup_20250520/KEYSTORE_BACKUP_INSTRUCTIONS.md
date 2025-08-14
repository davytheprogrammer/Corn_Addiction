# Keystore Backup Instructions for Anicare App

## Critical Files to Backup

These files are essential for publishing updates to your app on the Google Play Store:

1. **Android Keystore File**: 
   - Location: `android/app/upload-keystore.jks`
   - This is the most critical file. If you lose this, you cannot update the same app on the Play Store.

2. **Keystore Configuration File**:
   - Location: `android/key.properties`
   - Contains passwords and alias information for your keystore

## Backup Instructions

### Option 1: Secure Cloud Storage (Recommended)

1. Create a secure folder in a trusted cloud storage service (Google Drive, Dropbox, etc.)
2. Upload both files to this location
3. Enable 2-factor authentication on your cloud storage account
4. Consider encrypting these files before uploading (you can use a tool like 7zip with password protection)

### Option 2: Physical Backup

1. Copy both files to a USB drive
2. Store the USB drive in a secure location
3. Consider making multiple copies stored in different locations

### Option 3: Password Manager

1. Some password managers allow secure file attachments
2. You can store both files in your password manager along with the keystore credentials

## Keystore Information

Keep a record of this information in a secure password manager:

- **Keystore Password**: `ogegaman`
- **Key Password**: `ogegaman`
- **Key Alias**: `upload`
- **Keystore File Location**: `android/app/upload-keystore.jks`
- **Certificate Validity**: 10,000 days from May 20, 2025
- **Certificate Owner**: CN=davis, OU=aniwise, O=aniwise, L=kisii, ST=myanza, C=ny

## GitHub Repository Instructions

When pushing to GitHub:
1. Your `.gitignore` file should already exclude the keystore and key.properties files
2. Double-check that sensitive files are not committed before pushing
3. Your repository is private, but still follow best practices

## Restoring on a New Machine

To set up app signing on a new development machine:

1. Clone your GitHub repository
2. Restore the keystore and key.properties files to their correct locations:
   - Copy `upload-keystore.jks` to `android/app/upload-keystore.jks`
   - Copy `key.properties` to `android/key.properties`
3. Verify the build works with: `flutter build appbundle`

Remember: Never lose these files, or you'll lose the ability to update your app on the Play Store!
