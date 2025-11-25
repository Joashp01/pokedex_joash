// Import our custom User model
import 'package:pokedex_joash/models/user.dart';
// Import Firebase Authentication package for handling user login/registration
// 'as fb' means we can use 'fb.' prefix to access Firebase classes
// WHY: Prevents naming conflicts if we have our own User class
import 'package:firebase_auth/firebase_auth.dart' as fb;

// This class handles all authentication operations (login, register, logout)
// WHY: Centralizing authentication logic makes it easy to manage user accounts
// and keeps security-related code in one place
class AuthService{

  // Private instance of Firebase Authentication
  // The underscore (_) makes this variable private to this class
  // 'instance' gives us the single shared Firebase Auth object for the entire app
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  // Private helper function to convert Firebase User to our custom User model
  // WHAT: Takes Firebase's User object and creates our simplified User object
  // WHY: Firebase User has lots of properties we don't need. We only need the uid (user ID)
  //
  // The question marks (?) mean these can be null (no user logged in)
  // This is a ternary operator: condition ? valueIfTrue : valueIfFalse
  User? _userFromFirebaseUser(fb.User? user){
    return user != null ? User(uid: user.uid) : null;
  }

  // Stream that notifies us whenever the user's authentication state changes
  // WHAT: A Stream is like a pipe that continuously sends data
  // WHY: We want to know immediately when users log in or out, so we can update the UI
  //
  // 'get' makes this a getter - we can access it like a property: authService.user
  // Stream<User?> means it sends User objects (or null) over time
  Stream<User?> get user {
    // authStateChanges() is a Stream from Firebase that emits events when:
    // - User logs in (sends the user)
    // - User logs out (sends null)
    // - App starts with a user already logged in (sends the user)
    //
    // .map() transforms each Firebase User into our custom User model
    return _auth.authStateChanges()
    .map((fb.User? user) => _userFromFirebaseUser(user));
  }

  // Signs in an existing user with email and password
  // WHAT: Attempts to log in a user using their credentials
  // WHY: Users need to access their account to save favorite Pokemon, etc.
  //
  // Parameters:
  //   email: User's email address
  //   password: User's password
  //
  // Returns: User object if successful, null if login fails
  // Future means this takes time (needs to contact Firebase servers)
  // async means we can use 'await' to wait for the result
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    // try-catch block to handle errors gracefully
    // WHY: Network issues or wrong passwords shouldn't crash the app
    try{
      // Call Firebase to sign in with the provided credentials
      // await means "wait for Firebase to respond before continuing"
      // UserCredential contains the result of the sign-in attempt
      fb.UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Extract the user from the result
      // user will be null if sign-in failed somehow
      fb.User? user = result.user;

      // Convert Firebase User to our custom User model and return it
      return _userFromFirebaseUser(user);
    }catch(e){
      // If anything goes wrong (wrong password, no internet, etc.)
      // Print the error for debugging and return null
      // null tells the calling code that sign-in failed
      print('Error signing in : $e');
      return null;
    }
  }

  // Registers a new user with email and password
  // WHAT: Creates a brand new user account in Firebase
  // WHY: New users need to create an account before using the app
  //
  // Parameters:
  //   email: The email address the user wants to register with
  //   password: The password the user chooses (Firebase requires minimum 6 characters)
  //
  // Returns: User object if successful, null if registration fails
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    // try-catch to handle errors (email already in use, weak password, no internet, etc.)
    try{
      // Debug print to track when registration starts
      print(' Pokedex registration strating ');

      // Call Firebase to create a new user account
      // This creates the account on Firebase servers and returns credentials
      // await means we wait for Firebase to finish creating the account
      fb.UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Extract the user from the result
      fb.User? user = result.user;

      // Double-check that we actually got a user back
      // This is a safety check - registration should always return a user
      if (user == null){
        print('User is null after registration ');
        return null;
      }

      // Debug print to confirm user was created successfully
      // uid (user ID) is a unique identifier Firebase assigns to each user
      print ('Pokedex user created with uid: ${user.uid}');

      // Convert Firebase User to our custom User model and return it
      return _userFromFirebaseUser(user);

    }catch(e){
      // If registration fails (email already taken, invalid email format, etc.)
      // Print the error for debugging and return null
      // Common errors: email already in use, weak password, no internet connection
      print('Error registering : $e');
      return null;
    }
  }

  // Signs out the current user
  // WHAT: Logs out the currently signed-in user
  // WHY: Users need a way to securely log out of their account
  //
  // Returns: Future<void> means this function completes a task but doesn't return a value
  // void = nothing to return, just performs an action
  Future<void> signOut() async {
    // try-catch to handle any errors during sign-out
    try{
      // Call Firebase to sign out the current user
      // await waits for the sign-out to complete before continuing
      // After this, the authStateChanges stream (from the 'user' getter above)
      // will automatically emit null, notifying the app that no user is logged in
      return await _auth.signOut();
    }catch(e){
      // If sign-out fails (rare, but could happen with network issues)
      // Print the error for debugging
      // Note: We don't return anything here because the function is void
      print('Error signing out : $e');
    }
  }

}
