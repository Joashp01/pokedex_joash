# Pokédex App

A modern, feature-rich Pokédex application built with Flutter that allows users to browse, search, and favorite Pokémon with offline support.

## Features

- 📱 **Cross-Platform**: Works on Web, iOS, Android, Windows, macOS, and Linux
- 🔍 **Smart Search**: Search Pokémon by name or ID using the official PokéAPI
- ❤️ **Favorites System**: Mark your favorite Pokémon and sync across devices
- 🌐 **Offline Mode**: Access your favorite Pokémon even without internet
- 🎨 **Dark/Light Theme**: Toggle between dark and light modes
- 🔊 **Audio Experience**: Play Pokémon cries and theme song
- 📊 **Detailed Stats**: View comprehensive Pokémon stats, abilities, and evolution chains
- 🔐 **User Authentication**: Secure Firebase authentication
- 💾 **Data Persistence**: Local caching for offline access
- 📱 **Responsive Design**: Optimized for both mobile and web (max-width constraints)

## Tech Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language

### State Management
- **Provider** - Reactive state management solution

### Backend & Services
- **Firebase Auth** - User authentication
- **Cloud Firestore** - User data and favorites storage
- **PokéAPI** - Pokémon data source (https://pokeapi.co)

### Key Dependencies
```yaml
dependencies:
  provider: ^6.1.5+1
  firebase_core: ^4.2.1
  firebase_auth: ^6.1.2
  cloud_firestore: ^6.1.0
  http: ^1.6.0
  shared_preferences: ^2.2.2
  connectivity_plus: ^6.1.2
  audioplayers: ^6.1.0
```

## Setup Instructions

### Prerequisites
- Flutter SDK (>=3.10.0)
- Dart SDK
- Firebase account
- IDE (VS Code, Android Studio, or IntelliJ)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pokedex_joash
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**

   a. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)

   b. Enable Authentication (Email/Password)

   c. Create a Firestore database

   d. Add your Firebase configuration:
      - For Web: Update Firebase options in `lib/main.dart`
      - For Mobile: Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

4. **Run the app**
   ```bash
   # Web
   flutter run -d chrome

   # Mobile
   flutter run

   # Windows
   flutter run -d windows

   # macOS
   flutter run -d macos

   # Linux
   flutter run -d linux
   ```

## Architecture & Design Decisions

### Architecture Pattern: MVC (Model-View-Controller)

```
lib/
├── models/          # Data models (Pokemon, User)
├── views/           # UI screens
├── controllers/     # Business logic (PokemonController)
├── services/        # External services (API, Auth, Storage)
├── providers/       # Theme provider
├── widgets/         # Reusable UI components
└── shared/          # Constants and utilities
```

### Key Architectural Decisions

#### 1. **Provider for State Management**
- **Why**: Lightweight, officially recommended by Flutter team
- **Benefits**: Easy to understand, minimal boilerplate, great for medium-sized apps
- Manages app-wide state (user data, Pokemon list, theme)

#### 2. **Separation of Concerns**
- **Models**: Pure data classes
- **Views**: UI-only logic
- **Controllers**: Business logic and state management
- **Services**: External interactions (API, database, storage)

#### 3. **API Strategy**
- **Primary**: Uses PokéAPI endpoint `GET /pokemon/{id or name}` for direct searches
- **Fallback**: Client-side filtering of cached Pokémon list for partial matches
- **Benefits**: Faster exact searches, reduced API calls

#### 4. **Offline-First Favorites**
- Favorites cached locally using SharedPreferences
- Loads on app start for offline access
- Syncs with Firestore when online
- **Why**: Better UX, works without internet

#### 5. **Lazy Loading with Pagination**
- Loads 20 Pokémon at a time
- Infinite scroll loads more on demand
- **Benefits**: Better performance, reduced memory usage

#### 6. **Responsive Design**
- Max-width constraints (1200px for main content, 600px for auth)
- Adapts to mobile, tablet, and desktop
- **Why**: Better UX on web and large screens

#### 7. **Firebase Integration**
- Authentication for user management
- Firestore for favorites synchronization
- Platform-specific initialization (Web vs Mobile)

#### 8. **Connectivity Monitoring**
- Real-time network status detection
- Automatic favorites-only mode when offline
- Visual indicator for offline state
- **Benefits**: Transparent offline experience

#### 9. **Local Caching Strategy**
- Favorited Pokémon stored separately from main list
- Prevents duplicates in "All Pokémon" view
- Only appears in favorites filter
- **Why**: Cleaner separation, better performance

#### 10. **Audio Integration**
- Theme song with play/pause controls
- Pokémon cry sounds on card tap
- **Why**: Enhanced user experience, nostalgic touch

## Project Structure

### Models (`lib/models/`)
- `pokemon.dart` - Pokémon data structures (Pokemon, PokemonListItem, EvolutionStage, PokemonStat)
- `user.dart` - User model with favorite Pokémon IDs

### Views (`lib/views/`)
- `wrapper.dart` - Authentication wrapper
- `authenticate/` - Sign in and registration screens
- `home/` - Main Pokédex screens (list and detail views)

### Controllers (`lib/controllers/`)
- `pokemon_controller.dart` - Manages Pokémon state, favorites, search, pagination, and offline mode

### Services (`lib/services/`)
- `api_service.dart` - PokéAPI integration
- `auth.dart` - Firebase authentication
- `database.dart` - Firestore operations
- `local_storage.dart` - SharedPreferences caching
- `pokemon_sound.dart` - Audio playback

### Providers (`lib/providers/`)
- `theme_provider.dart` - Dark/light theme management

### Widgets (`lib/widgets/`)
Reusable UI components:
- `pokemon_list_card.dart` - Pokémon card in list
- `pokemon_search_bar.dart` - Search input
- `pokemon_image.dart` - Pokémon sprite display
- `pokemon_stats_card.dart` - Stats visualization
- `pokemon_evolution_chain.dart` - Evolution display
- And more...

## Key Features Implementation

### Favorites System
1. User favorites stored in Firestore (`users/{uid}/favoritePokemonIds`)
2. Local cache in SharedPreferences for offline access
3. Separate `_favoritedPokemonCache` prevents mixing with main list
4. Real-time sync when toggling favorites

### Search Functionality
1. Tries exact match using `GET /pokemon/{query}`
2. Falls back to client-side filtering if no exact match
3. Supports both name and ID searches
4. Returns up to 50 results

### Offline Mode
1. Detects network status with `connectivity_plus`
2. Loads favorites from local cache when offline
3. Shows orange banner indicating offline status
4. Automatically refreshes when connection restored

### Pagination
1. Loads 20 Pokémon per page
2. Infinite scroll triggers at 200px from bottom
3. Maintains scroll position
4. Prevents duplicate API calls

## Firebase Configuration

### Firestore Structure
```
users/
  {userId}/
    email: string
    favoritePokemonIds: array<number>
```

### Security Rules (Recommended)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Testing

Run tests:
```bash
flutter test
```

The project includes widget tests for:
- Pokemon list view
- Pokemon detail view
- Controllers
- Models
- Services

## Performance Optimizations

1. **Image Caching**: Network images cached automatically by Flutter
2. **Lazy Loading**: Only loads visible Pokémon
3. **Debouncing**: Search with slight delay to reduce API calls
4. **Offline Cache**: Favorites stored locally
5. **Efficient State Updates**: Provider only notifies when necessary
6. **Null-Aware Operators**: Optimized null checks with `??=`

## Known Limitations

1. Search fallback requires loading all 2000+ Pokémon names (cached after first load)
2. Evolution chain only shows linear progressions
3. Audio files depend on external URLs

## Future Enhancements

- [ ] Pokémon comparison feature
- [ ] Advanced filtering (type, generation, stats)
- [ ] User profiles with badges/achievements
- [ ] Social features (share favorites)
- [ ] Multi-language support
- [ ] Advanced stats visualization (charts)
- [ ] Team builder feature
- [ ] Move details and effectiveness calculator

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [PokéAPI](https://pokeapi.co) - The RESTful Pokémon API
- [Firebase](https://firebase.google.com) - Backend services
- [Flutter](https://flutter.dev) - UI framework
- Pokémon sprites and data © Nintendo/Game Freak


**Built with ❤️ using Flutter**
