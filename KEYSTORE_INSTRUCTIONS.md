# Keystore Instructions for Anicare App

## Keystore Information
- **Keystore Location:** `/home/ogega/Projects/Anicare/android/app/upload-keystore.jks`
- **Keystore Alias:** `upload`
- **Keystore Validity:** 10,000 days from May 20, 2025
- **Certificate Information:** CN=davis, OU=aniwise, O=aniwise, L=kisii, ST=myanza, C=ny

## Important Notes
1. **KEEP YOUR KEYSTORE SECURE**
   - This keystore is essential for future app updates to the Play Store
   - If you lose this keystore, you will NOT be able to update your app on the Play Store
   - Consider backing up the keystore file in a secure location

2. **Keystore Password Management**
   - The keystore password has been set as "ogegaman"
   - Do not commit files with the real password to public repositories
   - Consider using a password manager to store the password

3. **For Future App Updates**
   - When building a release version, ensure the keystore configuration in `android/key.properties` is correct
   - Use the same keystore for all future updates to the Play Store

## Build Commands
To build a release AAB (Android App Bundle) for the Play Store:
```bash
flutter build appbundle
```

To build a release APK:
```bash
flutter build apk --release
```

## Verifying Signing
To verify that your app is properly signed with the release key:
```bash
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

## In Case of Keystore Loss
If you lose your keystore:
1. You'll need to create a new app listing on the Play Store
2. You'll need to use a different package name for your app
3. Users will need to download your app as a new app, not an update

Keep this keystore file and password in a secure location!
