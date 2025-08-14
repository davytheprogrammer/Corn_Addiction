# GitHub Usage Instructions for Anicare App

## Safely Using GitHub with Your Flutter App

This guide explains how to safely manage your Flutter app on GitHub while protecting sensitive files like keystores and API keys.

## What's Excluded from Git

Your repository is configured to exclude these sensitive files:

1. **Keystore Files**: 
   - `android/app/upload-keystore.jks`
   - Any other `.jks` or `.keystore` files

2. **Keystore Configuration**:
   - `android/key.properties` (contains passwords)

3. **Google Service Configuration**:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

## Workflow for GitHub Usage

### Initial Setup

1. Clone your repository:
   ```
   git clone https://github.com/yourusername/Anicare.git
   cd Anicare
   ```

2. Restore your keystore files using the backup script:
   ```
   ./backup_keystore.sh restore
   ```
   (This requires having a backup ZIP file in the current directory)

3. Install Flutter dependencies:
   ```
   flutter pub get
   ```

### Regular Development

1. Make your code changes
2. Test locally:
   ```
   flutter run
   ```
3. Commit your changes:
   ```
   git add .
   git commit -m "Your descriptive commit message"
   ```
4. Push to GitHub:
   ```
   git push
   ```

### Releasing a New Version

1. Update your app version in `pubspec.yaml`
2. Make sure your keystore files are in place:
   ```
   ./backup_keystore.sh restore
   ```
3. Build your release bundle:
   ```
   flutter build appbundle
   ```
4. The signed app bundle will be at:
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```
5. Upload this file to the Google Play Console

## New Team Member Onboarding

When a new team member needs to work on the app:

1. They should clone the repository
2. You should securely share the keystore backup with them
3. They should run the restore script

## Verify Files Are Excluded

Before pushing sensitive changes, always verify excluded files:

```
git status
```

This should NOT show any of the sensitive files listed above.

## Important Reminders

1. **NEVER** commit keystore files to GitHub, even if your repository is private
2. Create regular backups of your keystore files
3. Store backups securely (password manager, encrypted USB drive, etc.)
4. Remember your keystore password - without it, you can't update your app!
