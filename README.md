# 🎵 Mini Music App

A Flutter music player application built as part of a technical assessment. Features mock authentication, a home feed with track listings, a fully functional music player, artist profiles, and a favorites system with local persistence.

## Features

### Core
- **Mock Login** — Simple email/password authentication with form validation and persistent login state
- **Home Feed** — Displays a list of 10 tracks from mock data with album art, artist names, and durations
- **Music Player** — Full audio playback using `just_audio` with play/pause and seek bar controls
- **Artist Profile** — Detailed artist page with bio, monthly listeners, and their discography

### Bonus
- **Favorites** — Heart icon toggle on tracks with `SharedPreferences` persistence and a dedicated favorites tab
- **Session Restore** — Remembers the last played track and loads it on app reopen

### Player Behavior
- Only one track plays at a time
- Playing a new track automatically stops the previous one
- Currently playing track is visually highlighted with a green border and icon

## Architecture

The project follows an **MVVM (Model-View-ViewModel)** pattern with **feature-based** folder organization:

```
lib/
├── main.dart                      # Entry point, auth check, session restore
├── core/
│   ├── theme/app_theme.dart       # Dark theme, colors, typography
│   ├── models/                    # Data classes (TrackModel, ArtistModel)
│   └── widgets/                   # Reusable UI components
├── features/
│   ├── auth/                      # Login screen + auth viewmodel
│   ├── home/                      # Track feed + repository layer
│   ├── player/                    # Audio player + mini player + full screen
│   ├── artist/                    # Artist profile page
│   └── favorites/                 # Favorites list + persistence
└── data/
    └── mock_data.dart             # Mock tracks and artists
```

### Layer Separation
| Layer | Responsibility | Example |
|-------|---------------|---------|
| **View** | UI rendering, user interaction | `login_page.dart`, `home_page.dart` |
| **ViewModel** | Business logic, state management | `auth_viewmodel.dart`, `player_viewmodel.dart` |
| **Data/Repository** | Data access, mock API simulation | `home_repository.dart`, `mock_data.dart` |

## Tech Stack

| Library | Purpose | Why |
|---------|---------|-----|
| `flutter_riverpod` | State management | Clean separation of concerns, no boilerplate. Preferred over Provider for better testability. |
| `just_audio` | Audio playback | Most popular Flutter audio package. Handles streaming, seeking, and player state. |
| `shared_preferences` | Local persistence | Lightweight key-value store for favorites, login state, and session restore. |
| `cached_network_image` | Image caching | Smooth album art loading with placeholders and error fallbacks. |
| `google_fonts` | Typography | Professional Poppins font without bundling font files. |

## Getting Started

### Prerequisites
- Flutter SDK >= 3.4.0
- Dart SDK >= 3.4.0
- Android Studio / VS Code with Flutter extension

### Run the project
```bash
# Clone the repository
git clone https://github.com/Pushpendra-7-ux/music_app_assessment.git
cd music_app_assessment

# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run
```

### Build APK
```bash
flutter build apk --release
```
The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`

## Key Decisions & Tradeoffs

1. **Mock data instead of API** — The assessment allows mock data. I used a `MockData` class with a simulated 600ms delay to demonstrate proper loading states without the complexity of a backend.

2. **SharedPreferences over Hive/SQLite** — For the scope of this app (favorites list + session ID), SharedPreferences is sufficient and avoids adding heavy database dependencies.

3. **Dark theme only** — Music apps conventionally use dark themes (Spotify, Apple Music, YouTube Music). A single well-polished theme is better than a half-baked light/dark toggle.

4. **No server/backend** — The assessment says "mock API/JSON is fine", so all data lives in `mock_data.dart`. The repository layer is structured so swapping in a real API would only require changing `HomeRepository`.

5. **Riverpod over BLoC** — Riverpod offers cleaner syntax, better dependency injection, and simpler testing compared to BLoC's verbose event/state pattern. For a project of this size, Riverpod is the right choice.

6. **SoundHelix sample audio** — Used free CC-licensed audio from SoundHelix for actual playable tracks, avoiding copyright issues.

## Loading & Error States

Every screen handles three states:
- **Loading** — Circular progress indicator while data loads
- **Error** — Error icon with a "Try Again" button
- **Empty** — Descriptive empty state with an icon and helpful message

## License

This project was built for assessment purposes.
