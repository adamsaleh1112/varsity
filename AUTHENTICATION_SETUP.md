# Varsity App - Authentication & Team Following Setup

## Overview
This guide walks you through implementing Apple Sign-In and basic team following functionality for the Varsity iOS app.

## Prerequisites
- Xcode 15+
- iOS 17+ target
- Active Apple Developer Account
- Supabase project with existing database

## Step 1: Xcode Project Configuration

### Add Required Capabilities
1. Open your Xcode project
2. Select your app target
3. Go to "Signing & Capabilities"
4. Add "Sign in with Apple" capability

### Add Required Frameworks
Add these to your project dependencies:
```swift
// In Package.swift or through Xcode Package Manager
dependencies: [
    .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0")
]
```

### Update Info.plist
Add Sign in with Apple configuration:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.yourcompany.varsity.auth</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.yourcompany.varsity</string>
        </array>
    </dict>
</array>
```

## Step 2: Database Setup

### Run SQL Script
1. Open your Supabase dashboard
2. Go to SQL Editor
3. Run the provided `database_setup.sql` script
4. This creates:
   - `users` table (extends auth.users)
   - `user_follows` table for team following
   - Row Level Security policies
   - Automatic user profile creation triggers

### Configure Supabase Auth
1. In Supabase dashboard, go to Authentication > Settings
2. Enable "Apple" provider
3. Configure Apple OAuth:
   - Services ID: `com.yourcompany.varsity.auth`
   - Team ID: Your Apple Developer Team ID
   - Key ID: From Apple Developer Console
   - Private Key: Download from Apple Developer Console

## Step 3: iOS Implementation

### Update App Entry Point
Replace your main App file content:

```swift
import SwiftUI

@main
struct VarsityApp: App {
    var body: some Scene {
        WindowGroup {
            AuthenticatedAppView()
        }
    }
}
```

### Key Files Created
The following files have been created for you:

1. **Models/User.swift** - User and UserFollow data models
2. **Services/AuthenticationManager.swift** - Handles Apple Sign-In flow
3. **Services/UserFollowService.swift** - Manages team following
4. **ViewModels/UserFollowViewModel.swift** - UI state for following
5. **Views/LoginView.swift** - Sign-in screen
6. **Views/AuthenticatedAppView.swift** - App routing based on auth state

### Integration Steps

#### 1. Fix Import Issues
The current files have import errors. You'll need to:
- Ensure Supabase package is properly added
- Make sure all model files are included in your target
- Verify SupabaseManager exists and is accessible

#### 2. Update Existing Views
Add team following to your existing VarsityHomeView:

```swift
// Add to VarsityHomeView
@StateObject private var followViewModel = UserFollowViewModel()
@EnvironmentObject var authManager: AuthenticationManager

// In school button ForEach, add follow button:
Button(action: {
    if let userId = authManager.currentUser?.id {
        Task {
            await followViewModel.toggleFollow(userId: userId, schoolId: school.id)
        }
    }
}) {
    Image(systemName: followViewModel.isFollowing(school.id) ? "heart.fill" : "heart")
        .foregroundColor(followViewModel.isFollowing(school.id) ? .red : .white)
}
```

#### 3. Filter Games by Followed Teams
Update your GamesViewModel to filter by followed teams:

```swift
func loadGamesForFollowedTeams(followedSchoolIds: Set<UUID>) async {
    // Filter games to show followed teams first
    let allGames = try await service.fetchRecentGames()
    let followedGames = allGames.filter { game in
        // Check if either team belongs to a followed school
        followedSchoolIds.contains(game.homeTeam.schoolId) || 
        followedSchoolIds.contains(game.awayTeam.schoolId)
    }
    // Show followed games first, then others
    gameCards = followedGames + allGames.filter { !followedGames.contains($0) }
}
```

## Step 4: Apple Developer Console Setup

### Create Services ID
1. Go to Apple Developer Console
2. Create new Services ID: `com.yourcompany.varsity.auth`
3. Enable "Sign in with Apple"
4. Configure domains and redirect URLs for Supabase

### Create Key for Apple Sign-In
1. Create new Key in Apple Developer Console
2. Enable "Sign in with Apple"
3. Download the .p8 key file
4. Note the Key ID

## Step 5: Testing

### Test Authentication Flow
1. Run app in simulator or device
2. Tap "Sign in with Apple"
3. Complete Apple ID authentication
4. Verify user profile is created in Supabase
5. Test team following functionality

### Verify Database
Check Supabase dashboard:
- Users table should have new entries
- user_follows table should track followed teams
- RLS policies should prevent unauthorized access

## Step 6: Production Considerations

### Security
- Enable Row Level Security on all tables
- Validate JWT tokens server-side
- Implement proper error handling
- Add rate limiting for API calls

### User Experience
- Add loading states during authentication
- Handle network errors gracefully
- Implement offline support for basic functionality
- Add onboarding flow for new users

### Performance
- Cache user preferences locally
- Implement efficient data syncing
- Optimize database queries with proper indexes

## Troubleshooting

### Common Issues
1. **Import Errors**: Ensure Supabase package is properly installed
2. **Authentication Fails**: Check Apple Developer Console configuration
3. **Database Errors**: Verify RLS policies and table permissions
4. **UI Not Updating**: Ensure @StateObject and @EnvironmentObject are used correctly

### Debug Steps
1. Check Xcode console for detailed error messages
2. Verify Supabase project URL and anon key
3. Test database queries in Supabase SQL editor
4. Use Xcode debugger to trace authentication flow

## Next Steps

After basic authentication is working:
1. Add Google Sign-In support
2. Implement push notifications for followed teams
3. Add user profile management
4. Create team discovery and recommendation features
5. Add social features (sharing, comments, etc.)

## Support
- Check Supabase documentation for auth issues
- Review Apple Sign-In documentation for iOS integration
- Test thoroughly on both simulator and physical devices
