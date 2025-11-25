// Import statements - bring in the screens and tools we need
import 'package:pokedex_joash/views/authenticate/authenticate.dart';  // Login/Register screens
import 'package:pokedex_joash/views/home/poke_home.dart';  // Main Pokemon app screen
import 'package:flutter/material.dart';  // Flutter UI library
import 'package:provider/provider.dart';  // To access our providers
import 'package:pokedex_joash/models/user.dart';  // Our User model

// ======================================================================
// WRAPPER WIDGET - The "Traffic Controller" of Our App
// ======================================================================
//
// WHAT IS A WRAPPER?
// A wrapper is a widget that "wraps" around the app and makes routing decisions.
// Think of it as a security guard at the entrance of a building:
// - If you have an ID badge (logged in), you can enter the main area
// - If you don't have an ID badge (not logged in), you go to the lobby (login screen)
//
// WHY USE A WRAPPER?
// 1. Automatic Navigation: When auth state changes, the wrapper automatically
//    shows the right screen without us writing complex navigation code
// 2. Centralized Logic: All authentication-based routing is in ONE place
// 3. Reactive: Because it listens to the StreamProvider, it updates in real-time
//    when users log in or out
// 4. Clean Code: Separates navigation logic from UI code
//
// HOW IT WORKS:
// The Wrapper listens to the User stream from Firebase (via Provider)
// - When user = null → Show Authenticate screen (login/register)
// - When user = User object → Show PokemonListView (main app)
//
// ======================================================================

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider.of<User?>(context) - This is HOW we read data from a provider
    //
    // Breaking it down:
    // - Provider.of<Type>() says "find a provider that holds data of this Type"
    // - <User?> means we're looking for a User object (or null if no user)
    // - (context) is needed to search up the widget tree to find the provider
    // - The '?' in User? means the value can be null (no user logged in)
    //
    // IMPORTANT: This widget will REBUILD whenever the User value changes!
    // This is the magic that makes authentication navigation automatic
    final user = Provider.of<User?>(context);

    // Debug print to see the current user state (helpful for development)
    print(user);

    // CONDITIONAL NAVIGATION - Show different screens based on authentication
    //
    // if (user == null) means "if there's no logged-in user"
    // - null = not authenticated → show login/register screens
    // - not null = authenticated → show the main Pokemon app
    //
    // This is called "conditional rendering" - showing different UI based on conditions
    if (user == null) {
      // User is NOT logged in → show authentication screens
      return const Authenticate();
    } else {
      // User IS logged in → show the main Pokemon list
      return const PokemonListView();
    }
  }
}
