# Firebase Setup Instructions

## Firestore Indexes Setup

The app requires composite indexes for optimal performance. Follow these steps:

### Option 1: Automatic Setup (Recommended)
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login to Firebase: `firebase login`
3. Initialize project: `firebase init firestore`
4. Deploy indexes: `firebase deploy --only firestore:indexes`

### Option 2: Manual Setup via Console
Visit the Firebase Console and create these composite indexes:

#### Streaks Collection Index
- Collection: `streaks`
- Fields:
  - `userId` (Ascending)
  - `isActive` (Ascending) 
  - `startDate` (Descending)
  - `__name__` (Descending)

#### Urge Logs Collection Index
- Collection: `urgeLogs`
- Fields:
  - `userId` (Ascending)
  - `timestamp` (Descending)
  - `__name__` (Descending)

### Option 3: Use the provided links
The error messages in your logs contain direct links to create the indexes:

1. **Streaks Index**: https://console.firebase.google.com/v1/r/project/cornaddiction-6728b/firestore/indexes?create_composite=ClNwcm9qZWN0cy9jb3JuYWRkaWN0aW9uLTY3MjhiL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy9zdHJlYWtzL2luZGV4ZXMvXxABGgwKCGlzQWN0aXZlEAEaCgoGdXNlcklkEAEaDQoJc3RhcnREYXRlEAIaDAoIX19uYW1lX18QAg

2. **Urge Logs Index**: https://console.firebase.google.com/v1/r/project/cornaddiction-6728b/firestore/indexes?create_composite=ClRwcm9qZWN0cy9jb3JuYWRkaWN0aW9uLTY3MjhiL2RhdGFiYXNlcy8oZGVmYXVsdCkvY29sbGVjdGlvbkdyb3Vwcy91cmdlTG9ncy9pbmRleGVzL18QARoKCgZ1c2VySWQQARoNCgl0aW1lc3RhbXAQAhoMCghfX25hbWVfXxAC

## Security Rules
The `firestore.rules` file contains security rules that ensure users can only access their own data.

Deploy rules with: `firebase deploy --only firestore:rules`

## Testing
After setting up indexes, restart your app and the Firestore errors should be resolved.