// Import statements - bring in our authentication screens
import 'package:pokedex_joash/views/authenticate/register.dart';  // Registration screen
import 'package:pokedex_joash/views/authenticate/sign_in.dart';  // Sign in screen
import 'package:flutter/material.dart';  // Flutter UI library

// ======================================================================
// AUTHENTICATE WIDGET - The Toggle Between Sign In and Register
// ======================================================================
//
// WHAT DOES THIS DO?
// This widget acts as a "switcher" between two screens:
// - Sign In screen (for existing users to log in)
// - Register screen (for new users to create an account)
//
// WHY USE A STATEFUL WIDGET?
// We need to remember which screen to show (sign in or register).
// This requires STATE - data that can change over time.
// - StatefulWidget can store and update state
// - When state changes, the widget rebuilds to show the new screen
//
// THE TOGGLE PATTERN:
// Users can switch between sign in and register without losing their place.
// Like a light switch - flip it to change between two options.
//
// ======================================================================

// StatefulWidget - This widget has STATE that can change
// It's split into two classes:
// 1. Authenticate (the widget itself) - immutable/unchanging
// 2. _AuthenticateState (the state) - mutable/can change
class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  // createState() creates the mutable state object for this widget
  // This is called only once when the widget is first created
  @override
  State<Authenticate> createState() => _AuthenticateState();
}

// _AuthenticateState - This class holds the STATE for our Authenticate widget
// The underscore _ makes it private (only usable in this file)
class _AuthenticateState extends State<Authenticate> {

  // STATE VARIABLE: showSignIn
  // This boolean (true/false) determines which screen to show
  // - true = show Sign In screen
  // - false = show Register screen
  //
  // Why start with 'true'? Most users are returning users who want to sign in
  bool showSignIn = true;

  // toogleView() - Function to SWITCH between sign in and register screens
  //
  // HOW IT WORKS:
  // 1. setState() tells Flutter "the state is changing, rebuild the widget"
  // 2. Inside setState(), we flip showSignIn to its opposite value
  //    - If showSignIn was true, it becomes false
  //    - If showSignIn was false, it becomes true
  // 3. This triggers build() to run again, showing the other screen
  //
  // WHY setState()?
  // Without setState(), changing showSignIn wouldn't update the UI
  // setState() is REQUIRED to make Flutter rebuild the widget with new data
  void toogleView(){
    setState(() => showSignIn = !showSignIn);
    // Note: '!' means NOT, so '!showSignIn' flips the value
    // If showSignIn is true, !showSignIn is false (and vice versa)
  }

  // build() - Describes what to show on screen
  // This runs whenever setState() is called or the widget needs to rebuild
  @override
  Widget build(BuildContext context) {

    // CONDITIONAL RENDERING - Show different screens based on showSignIn
    //
    // IMPORTANT: We pass toogleView as a parameter to both screens!
    // This is called "passing a callback function"
    // - The child screen (SignIn or Register) can call this function
    // - When called, it changes the state HERE in the parent
    // - This makes the screens switch
    //
    // Example flow:
    // 1. User is on SignIn screen
    // 2. User taps "Don't have an account? Register"
    // 3. SignIn screen calls toggleView()
    // 4. toggleView() changes showSignIn to false
    // 5. build() runs again and shows Register screen
    if(showSignIn){
      // Show Sign In screen and give it the toggle function
      // toggleView: toogleView means "pass our toogleView function as a parameter"
      return SignIn(toggleView: toogleView);
    }else{
      // Show Register screen and give it the toggle function
      return Register(toggleView: toogleView);
    }
  }
}
