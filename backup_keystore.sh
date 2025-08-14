#!/bin/bash
# Script to backup keystore files for Anicare app
# Updated: May 20, 2025

# Show usage information if no argument is provided
if [ "$#" -eq 0 ]; then
  echo "Usage: $0 [backup|restore|help]"
  echo ""
  echo "Commands:"
  echo "  backup    Create a backup of keystore files"
  echo "  restore   Restore keystore files from backup"
  echo "  help      Show this help message"
  echo ""
  exit 1
fi

# Help command
if [ "$1" == "help" ]; then
  echo "Anicare Keystore Backup Tool"
  echo "============================"
  echo ""
  echo "This tool helps you backup and restore the signing keystore"
  echo "files required to update your app on the Google Play Store."
  echo ""
  echo "Usage: $0 [backup|restore|help]"
  echo ""
  echo "Commands:"
  echo "  backup    Create a backup of keystore files"
  echo "  restore   Restore keystore files from a backup"
  echo "  help      Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 backup     # Creates a new backup"
  echo "  $0 restore    # Restores from a backup (interactive)"
  echo ""
  exit 0
fi

# Backup command
if [ "$1" == "backup" ]; then
  # Create backup directory
  BACKUP_DIR="anicare_keystore_backup_$(date +%Y%m%d)"
  mkdir -p "$BACKUP_DIR"

  # Copy keystore files
  echo "Backing up keystore files..."
  if [ -f "android/app/upload-keystore.jks" ]; then
    cp android/app/upload-keystore.jks "$BACKUP_DIR/"
    echo "✅ Keystore file backed up successfully"
  else
    echo "⚠️ Warning: Keystore file not found at android/app/upload-keystore.jks"
    exit 1
  fi

  if [ -f "android/key.properties" ]; then
    cp android/key.properties "$BACKUP_DIR/"
    echo "✅ Key properties file backed up successfully"
  else 
    echo "⚠️ Warning: Key properties file not found at android/key.properties"
    exit 1
  fi
  
  cp KEYSTORE_BACKUP_INSTRUCTIONS.md "$BACKUP_DIR/"

# Create a README file
cat > "$BACKUP_DIR/README.txt" << EOL
Anicare App Keystore Backup
Date: $(date)

This backup contains critical files required to publish updates to the Anicare app on Google Play Store.
DO NOT DELETE THESE FILES. Store them securely.

Contents:
- upload-keystore.jks: The signing keystore
- key.properties: Keystore configuration
- KEYSTORE_BACKUP_INSTRUCTIONS.md: Detailed backup instructions

For more information, see KEYSTORE_BACKUP_INSTRUCTIONS.md
EOL

# Create a ZIP archive with password protection
echo "Creating encrypted ZIP archive..."
echo "You'll be prompted for a password to encrypt the backup."
echo "REMEMBER THIS PASSWORD! Without it, you can't restore your keystore."
zip -e "$BACKUP_DIR.zip" -r "$BACKUP_DIR"

# Clean up temporary directory
rm -rf "$BACKUP_DIR"

echo ""
echo "✅ Backup complete! Archive created at $BACKUP_DIR.zip"
echo "   Store this file in a secure location (cloud storage, USB drive, etc.)"
echo "   Remember the password you used to encrypt this archive!"
echo ""
echo "To use this backup in a fresh clone of your GitHub repository:"
echo "   1. Clone your repository from GitHub"
echo "   2. Copy the backup ZIP to your project directory"
echo "   3. Run: ./backup_keystore.sh restore"
echo ""
exit 0
fi

# Restore command
if [ "$1" == "restore" ]; then
  # Find available backups
  BACKUPS=$(ls anicare_keystore_backup_*.zip 2>/dev/null)
  
  if [ -z "$BACKUPS" ]; then
    echo "❌ Error: No backup archives found in the current directory."
    echo "Please copy your backup ZIP file to this directory and try again."
    exit 1
  fi
  
  # If multiple backups found, let the user choose
  if [ $(echo "$BACKUPS" | wc -l) -gt 1 ]; then
    echo "Multiple backup archives found. Please select one:"
    select BACKUP_FILE in $BACKUPS; do
      if [ -n "$BACKUP_FILE" ]; then
        break
      else
        echo "Invalid selection. Please try again."
      fi
    done
  else
    BACKUP_FILE=$BACKUPS
  fi
  
  echo "Extracting $BACKUP_FILE..."
  echo "You'll be prompted for the password you used when creating the backup."
  
  # Extract the backup
  unzip "$BACKUP_FILE"
  BACKUP_DIR=$(echo "$BACKUP_FILE" | sed 's/\.zip$//')
  
  if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Error extracting backup. Was the password correct?"
    exit 1
  fi
  
  # Restore the files
  echo "Restoring keystore files..."
  
  # Ensure directories exist
  mkdir -p android/app
  
  if [ -f "$BACKUP_DIR/upload-keystore.jks" ]; then
    cp "$BACKUP_DIR/upload-keystore.jks" android/app/
    echo "✅ Keystore file restored"
  else
    echo "❌ Error: Keystore file not found in backup"
  fi
  
  if [ -f "$BACKUP_DIR/key.properties" ]; then
    cp "$BACKUP_DIR/key.properties" android/
    echo "✅ Key properties file restored"
  else
    echo "❌ Error: Key properties file not found in backup"
  fi
  
  # Clean up
  rm -rf "$BACKUP_DIR"
  
  echo ""
  echo "✅ Restore complete!"
  echo "You can now build and sign your app for the Play Store."
  echo "To build your app bundle, run:"
  echo "   flutter build appbundle"
  echo ""
  exit 0
fi

# If we get here, the command was invalid
echo "❌ Error: Unknown command '$1'"
echo "Valid commands are: backup, restore, help"
echo "Run '$0 help' for more information."
exit 1
