@echo off
echo Deploying Firebase Firestore rules and indexes...
echo.

echo Installing Firebase CLI (if not already installed)...
npm install -g firebase-tools

echo.
echo Logging into Firebase...
firebase login

echo.
echo Deploying Firestore rules...
firebase deploy --only firestore:rules

echo.
echo Deploying Firestore indexes...
firebase deploy --only firestore:indexes

echo.
echo Firebase deployment complete!
echo Your app should now work without Firestore index errors.
pause