## Version 1.5.3
- Added ability to share a vault to non-Proton users
- Added 2FA telemetry

## Version 1.5.2
Improvements:
- Improved AutoFill extension's reliability

Others:
- Bump core from 11.0.1 to 12.2.0
- Full sync animation

## Version 1.5.1
Bug fixes:
- Fixed TOTP URI automatically added to login items

Others:
- Share from item detail pages
- No more primary vault behind a feature flag
- Improved Rust library integration
- Improved copy for share flow
- Passwords showed with colors in full screen mode
- Removed non main vault items from autofill list for free users

## Version 1.5.0
Features:
- Added support for Italian, Georgian, Spanish, Spanish (Latin America), Belarusian, Czech, Finnish, Greek, Japanese, Korean, Polish, Portuguese, Portuguese (Brazil), Romanian, Slovak, Swedish, Turkish, Ukrainian & Vietnamese languages

Improvements:
- Improved AutoFill extension’s reliability
- Improved “Default browser” settings

Others:
- Only show secret when editing TOTP URI if the URI has default parameters
- Fixed empty initials when item titles contain only numbers
- Display a toast message after transferring ownership
- Integrated Rust library
- Added signature context when sharing vaults
- Integrated “Dynamic plans” behind a core’s feature flag

## Version 1.4.0
Features:
- Added support for German language
- Display sync progress during login and full sync
- Move items between vaults

Improvements:
- Able to quickly copy the content of notes

Bug Fixes:
- Corrected alphabetical sorting

Others:
- Migrated to SPM
- Mitigated logout issue
- Improved item creation sheet
- Improved swipe-to-delete for items on the search page
- Migrated to String Catalogs
- Swift 5.9 adapation
- Make use of Macro

## Version 1.3.0
Features:
- Added support for the French language
- Introduced credit card scanning functionality
- Enabled document scanning directly into notes

Improvements:
- Implemented monospaced font for improved password readability
- Included AutoFill activation instructions for macOS
- Enabled email editing for logins with associated aliases
- Added support for Firefox Focus browser

Bug fixes:
- Fixed an issue where items were not syncing when there were inactive user keys
- Addressed an issue where the "Generate Password" and "Scan TOTP URI" buttons were not displayed on iOS 15

Others:
- Allowed to set a PIN code for devices without a passcode
- Removed "Default browser" option on macOS
- Enhanced navigation system for better page coordination
- Spinner now persists after accepting invitations for smoother vault reloading
- Eliminated digit validation for PIN codes
- Added the possibility to filter logs (QA builds only)

Vault sharing (WIP):
- Access level updates
- Access revocation
- Shared vault icon

## Version 1.2.2
- Resolved an issue where search highlights were occasionally failing to appear
- Fixed no autofill suggestions after logging in

## Version 1.2.1
### Improvements
- Improved TOTP URI parsing
- Enhanced indexation of login items for AutoFill

### Fixes
- Fixed an issue where non-empty vaults couldn't be deleted
- Fixed a problem with permanently deleting items on iOS 15
- Resolved occasional crashes when authenticating with Face ID/Touch ID or PIN

## Version 1.2.0
### Features
- Able to filter items by type

### Improvements
- Tap to copy hidden custom fields

### Fixes
- Fix unresponsive search bar & vault switcher
- Fix aliases not created when editing login items
- Fix page scrolled to bottom when editing notes
- Fix confirm PIN code button hidden behind the keyboard

## Version 1.1.0
- Allow to use a custom PIN code to lock the app

## Version 1.0.3
- Added new report page
- Improved TabBar accessibility to work with VoiceOver
- Custom fields are now automatically focused when they are being created or edited
- Improved the search page responsiveness

## Version 1.0.2
- Bug fixes and improvements

## Version 1.0.1
- Initial version