// Import statements: These bring in external packages and files we need
import 'package:flutter/material.dart';  // Flutter's core UI library
import 'package:pokedex_joash/services/auth.dart';  // Our authentication service
import 'package:firebase_core/firebase_core.dart';  // Firebase initialization
import 'package:pokedex_joash/views/wrapper.dart';  // The wrapper that handles navigation
import 'package:provider/provider.dart';  // State management package
import 'package:pokedex_joash/models/user.dart';  // Our custom User model
import 'controllers/pokemon_controller.dart';  // Manages Pokemon data
import 'providers/theme_provider.dart';  // Manages app theme (light/dark mode)

// main() - This is the entry point of our Flutter app
// Every Flutter app starts by running this function
// The 'async' keyword means this function can wait for asynchronous operations (like Firebase setup)
void main() async {
  // STEP 1: Initialize Flutter's binding
  // This is REQUIRED before using any async operations in main()
  // It ensures Flutter is ready to handle platform-specific code before the app starts
  WidgetsFlutterBinding.ensureInitialized();

  // STEP 2: Initialize Firebase
  // Firebase is our backend service for authentication and database
  // We wrap it in try-catch to handle any errors gracefully
  try {
    // 'await' means "wait for Firebase to finish initializing before continuing"
    // Firebase needs to connect to our project settings before the app can use it
    await Firebase.initializeApp();
    print('Firebase initialized successfully ');
  } catch (e) {
    // If Firebase fails to initialize, print the error so we can debug
    // The app will continue running, but Firebase features won't work
    print(' Firebase initialized error : $e');
  }

  // STEP 3: Start the Flutter app
  // runApp() takes a widget (MyApp) and makes it the root of the widget tree
  runApp(const MyApp());
}

// MyApp - The root widget of our application
// StatelessWidget means this widget doesn't change over time (it's static)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // build() - This method describes what the widget looks like
  // It's called whenever the widget needs to be rendered on screen
  @override
  Widget build(BuildContext context) {
    // MultiProvider - This is a CRUCIAL part of state management!
    // It allows us to provide multiple pieces of data to the entire app
    // Any widget below this in the tree can access these providers
    // Think of it like a "shared storage" that all widgets can read from
    return MultiProvider(
      // The 'providers' list contains all the data we want to share
      providers: [
        // PROVIDER 1: StreamProvider for Authentication
        // This listens to Firebase auth changes in REAL-TIME
        // When a user logs in or out, all widgets listening to this will automatically update
        StreamProvider<User?>.value(
          // AuthService().user returns a Stream that emits user data
          // A Stream is like a river of data - it continuously flows and can change
          value: AuthService().user,

          // initialData is what we show before the stream has any data
          // null means "no user logged in yet" when the app first starts
          initialData: null,

          // catchError handles any errors from the authentication stream
          // If Firebase has a problem, we return null instead of crashing the app
          catchError: (context, error) {
            print('StreamProvider error : $error');
            return null;  // Treat errors as "no user logged in"
          },
        ),

        // PROVIDER 2: ChangeNotifierProvider for Theme
        // This manages the app's theme (light mode vs dark mode)
        // ChangeNotifier means it can notify widgets when the theme changes
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // PROVIDER 3: ChangeNotifierProvider for Pokemon Data
        // This manages all the Pokemon data (fetching, storing, updating)
        // Separates data logic from UI, making code cleaner and reusable
        ChangeNotifierProvider(create: (_) => PokemonController()),
      ],

      // Consumer - This widget LISTENS to changes from a provider
      // Whenever ThemeProvider changes, this Consumer rebuilds
      // This is how we make the UI react to theme changes
      child: Consumer<ThemeProvider>(
        // builder gets called whenever ThemeProvider notifies of changes
        // 'themeProvider' gives us access to the current theme settings
        builder: (context, themeProvider, child) {
          // MaterialApp - The root widget that provides Material Design
          // It sets up navigation, themes, and other app-wide settings
          return MaterialApp(
            title: 'Pokédex',  // App name shown in task switcher
            debugShowCheckedModeBanner: false,  // Hides the "DEBUG" banner

            // Theme settings from our ThemeProvider
            themeMode: themeProvider.themeMode,  // Current mode (light/dark/system)
            theme: ThemeProvider.lightTheme,  // Colors/styles for light mode
            darkTheme: ThemeProvider.darkTheme,  // Colors/styles for dark mode

            // home - The first screen users see when the app opens
            // Wrapper decides whether to show login screen or main app
            home: Wrapper(),
          );
        },
      ),
    );
  }
}
