// Import Flutter's material design widgets and components
import 'package:flutter/material.dart';

// Import SharedPreferences - allows us to save data on the device
// so that user preferences persist even after closing the app
import 'package:shared_preferences/shared_preferences.dart';

// =============================================================================
// THEME PROVIDER CLASS
// =============================================================================
// This class manages the app's theme (light/dark mode) for the entire application.
//
// WHY WE EXTEND ChangeNotifier:
// ChangeNotifier is part of Flutter's Provider package. It's a special class that
// allows us to notify other parts of the app when something changes.
//
// Think of it like a radio station:
// - The ThemeProvider is the radio station that broadcasts updates
// - Other widgets in the app are listeners (radios) that tune in
// - When we call notifyListeners(), it's like broadcasting a message
// - All listening widgets automatically rebuild with the new theme
//
// This is the STATE MANAGEMENT pattern - one source of truth that many
// widgets can listen to and react to changes automatically.
// =============================================================================
class ThemeProvider extends ChangeNotifier {
  // -------------------------------------------------------------------------
  // STATIC CONSTANT - Key for SharedPreferences
  // -------------------------------------------------------------------------
  // This is the "key" we use to save/load the theme preference.
  // Think of SharedPreferences like a dictionary/map where:
  // - Keys are strings (like 'theme_mode')
  // - Values are the data we want to save (like 'ThemeMode.dark')
  //
  // We use 'static const' because:
  // - static: This value belongs to the class itself, not any specific instance
  // - const: The value never changes (it's always 'theme_mode')
  static const String _themeKey = 'theme_mode';

  // -------------------------------------------------------------------------
  // PRIVATE VARIABLE - Current Theme Mode
  // -------------------------------------------------------------------------
  // The underscore (_) makes this variable private - only this class can
  // directly modify it. This prevents bugs from other parts of the app
  // accidentally changing the theme without saving it properly.
  //
  // ThemeMode has 3 possible values:
  // - ThemeMode.light: Always use light theme
  // - ThemeMode.dark: Always use dark theme
  // - ThemeMode.system: Follow the device's system setting (if user's phone
  //   is in dark mode, app will be dark; if phone is light, app will be light)
  //
  // We start with ThemeMode.system as the default.
  ThemeMode _themeMode = ThemeMode.system;

  // -------------------------------------------------------------------------
  // GETTER - Public access to theme mode
  // -------------------------------------------------------------------------
  // This is a "getter" - it lets other parts of the app READ the current
  // theme mode, but not change it directly. To change it, they must use
  // the setThemeMode() method, which ensures the change is also saved.
  ThemeMode get themeMode => _themeMode;

  // -------------------------------------------------------------------------
  // GETTER - Check if currently using dark mode
  // -------------------------------------------------------------------------
  // This getter returns true if dark mode is active, false if light mode is active.
  //
  // WHY THE LOGIC IS COMPLEX:
  // When _themeMode is set to ThemeMode.system, we need to check what the
  // device's system setting actually is. We do this by checking:
  // - WidgetsBinding.instance: Access to Flutter framework services
  // - platformDispatcher: Interface to the platform (Android/iOS)
  // - platformBrightness: The system's brightness setting
  //
  // If platformBrightness is Brightness.dark, the system is in dark mode.
  // If it's Brightness.light, the system is in light mode.
  //
  // If _themeMode is NOT system, we simply check if it equals ThemeMode.dark.
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Check the device's system setting
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    // Check if explicitly set to dark mode
    return _themeMode == ThemeMode.dark;
  }

  // -------------------------------------------------------------------------
  // CONSTRUCTOR - Runs when ThemeProvider is created
  // -------------------------------------------------------------------------
  // This is called when we first create an instance of ThemeProvider.
  // It immediately calls _loadTheme() to load the user's saved preference
  // from the device storage.
  //
  // WHY THIS MATTERS:
  // When the app starts, we want to remember what theme the user chose last time.
  // Without this, the theme would reset to system mode every time the app opens.
  ThemeProvider() {
    _loadTheme();
  }

  // -------------------------------------------------------------------------
  // PRIVATE METHOD - Load saved theme from device storage
  // -------------------------------------------------------------------------
  // This method retrieves the user's previously saved theme preference.
  //
  // WHAT IS SharedPreferences?
  // SharedPreferences is like a small database on the device that stores
  // simple data (strings, numbers, booleans). It's perfect for saving
  // user preferences like theme choice, because:
  // - Data persists even after closing the app
  // - Data persists even after phone restarts
  // - It's fast to read and write
  // - It's easy to use
  //
  // HOW THIS WORKS:
  // 1. Get access to SharedPreferences (await because it takes time)
  // 2. Try to get the saved string using our key ('theme_mode')
  // 3. If we find a saved value, convert it back to a ThemeMode
  // 4. Notify all listeners that the theme has loaded
  //
  // THE ASYNC/AWAIT PATTERN:
  // - 'async' means this function does work that takes time (reading from storage)
  // - 'await' means "wait for this to finish before continuing"
  // - 'Future<void>' means this returns a promise that will complete later
  Future<void> _loadTheme() async {
    // Get access to SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Try to get the saved theme string (returns null if nothing was saved)
    final savedTheme = prefs.getString(_themeKey);

    // If we found a saved theme, use it
    if (savedTheme != null) {
      // Convert the saved string back to a ThemeMode enum value
      // ThemeMode.values is a list of all possible ThemeMode values
      // firstWhere finds the one that matches our saved string
      // orElse provides a fallback if no match is found
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedTheme,
        orElse: () => ThemeMode.system,
      );

      // CRITICAL: Tell all listening widgets to rebuild with the loaded theme
      // Without this, the UI wouldn't update to show the loaded theme
      notifyListeners();
    }
  }

  // -------------------------------------------------------------------------
  // PUBLIC METHOD - Set a new theme mode
  // -------------------------------------------------------------------------
  // This is how other parts of the app can change the theme.
  //
  // WHAT HAPPENS WHEN WE CHANGE THE THEME:
  // 1. Update the local variable (_themeMode)
  // 2. Call notifyListeners() - this triggers a rebuild of ALL widgets
  //    that are listening to this ThemeProvider
  // 3. The entire app will immediately switch to the new theme
  // 4. Save the new preference to device storage so it persists
  //
  // WHY THE ORDER MATTERS:
  // We call notifyListeners() BEFORE saving to SharedPreferences so the
  // UI updates immediately. Saving to storage happens in the background.
  // This makes the theme change feel instant to the user.
  Future<void> setThemeMode(ThemeMode mode) async {
    // Update the theme mode
    _themeMode = mode;

    // Notify all listening widgets - the entire app rebuilds with new theme
    // This is the "magic" that makes the theme change propagate everywhere
    notifyListeners();

    // Save the new preference to device storage for next time
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString());
  }

  // -------------------------------------------------------------------------
  // PUBLIC METHOD - Toggle between light and dark theme
  // -------------------------------------------------------------------------
  // This is a convenience method for a common action: switching between
  // light and dark mode (ignoring system mode).
  //
  // HOW IT WORKS:
  // - If currently in light mode, switch to dark mode
  // - Otherwise (dark or system mode), switch to light mode
  //
  // This is useful for a theme toggle button in the app's settings.
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }

  // ===========================================================================
  // LIGHT THEME DEFINITION
  // ===========================================================================
  // This static variable defines the complete look and feel of the app
  // when in light mode.
  //
  // WHY IT'S STATIC:
  // We use 'static' because this theme is the same for all instances of
  // ThemeProvider. It's shared across the entire app and doesn't change
  // per instance. This saves memory and makes it clear that the theme
  // definition is a constant configuration.
  //
  // WHAT IS ThemeData?
  // ThemeData is Flutter's way of defining the visual appearance of your
  // entire app. Instead of setting colors and styles on every widget,
  // you define them once here, and all widgets automatically use these
  // settings. This ensures visual consistency across your entire app.
  // ===========================================================================
  static ThemeData lightTheme = ThemeData(
    // -------------------------------------------------------------------------
    // MATERIAL DESIGN 3
    // -------------------------------------------------------------------------
    // Material Design 3 (Material You) is Google's latest design system.
    // It features:
    // - More rounded corners and softer shapes
    // - Better color system with dynamic color generation
    // - Improved accessibility
    // - More expressive and personalized design
    //
    // By setting this to true, we get all the Material 3 improvements
    // automatically applied to our widgets.
    useMaterial3: true,

    // -------------------------------------------------------------------------
    // BRIGHTNESS
    // -------------------------------------------------------------------------
    // This tells Flutter that this is a light theme. Flutter uses this to
    // determine default colors for widgets that we don't explicitly style.
    // For example, text will default to dark colors on a light theme.
    brightness: Brightness.light,

    // -------------------------------------------------------------------------
    // COLOR SCHEME - The app's color palette
    // -------------------------------------------------------------------------
    // ColorScheme is Material Design's way of defining a complete color system.
    // Instead of just picking random colors, Material Design uses a scientific
    // approach to generate harmonious colors that work well together.
    //
    // WHAT IS ColorScheme.fromSeed?
    // This is Material Design 3's "magic" feature. You give it ONE color (the seed),
    // and it automatically generates a complete palette of harmonious colors:
    // - Primary colors (main brand color)
    // - Secondary colors (accent colors)
    // - Tertiary colors (additional accents)
    // - Error colors (for warnings/errors)
    // - Surface colors (backgrounds)
    // - And many more!
    //
    // All these colors are scientifically calculated to look good together
    // and meet accessibility standards.
    colorScheme: ColorScheme.fromSeed(
      // Our brand color - a vibrant red (0xFFE63946 is hex color notation)
      // The 0xFF at the start represents full opacity (alpha = 255)
      seedColor: const Color(0xFFE63946),

      // Specify this is for light mode
      brightness: Brightness.light,

      // Override the generated primary color with our exact brand color
      primary: const Color(0xFFE63946),

      // Secondary color - a lighter, complementary red
      secondary: const Color(0xFFFF6B6B),

      // Surface color - used for backgrounds of components like Cards
      surface: Colors.white,
    ),

    // -------------------------------------------------------------------------
    // CARD THEME - Styling for Card widgets
    // -------------------------------------------------------------------------
    // Cards are common UI components used to group related information.
    // In this app, Pokemon details are likely shown in cards.
    //
    // By defining CardTheme here, every Card widget in the app will
    // automatically have these styles without needing to specify them
    // individually.
    cardTheme: CardThemeData(
      // elevation: How much "shadow" the card has (0 = flat, no shadow)
      // Modern Material 3 design often uses flat cards (elevation 0)
      // and relies on color/borders to separate content instead
      elevation: 0,

      // shape: Defines the border and corners of the card
      // RoundedRectangleBorder creates rounded corners (borderRadius: 20)
      // This gives cards a soft, modern appearance
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      // color: The background color of cards
      color: Colors.white,
    ),

    // -------------------------------------------------------------------------
    // APP BAR THEME - Styling for the top navigation bar
    // -------------------------------------------------------------------------
    // The AppBar is the bar at the top of most screens that shows the
    // screen title and navigation buttons.
    //
    // This theme applies to all AppBar widgets in the app automatically.
    appBarTheme: const AppBarTheme(
      // elevation: No shadow under the app bar (modern flat design)
      elevation: 0,

      // centerTitle: Centers the title text in the app bar
      // On iOS this is default, on Android it's normally left-aligned
      centerTitle: true,

      // iconTheme: Styling for icons in the app bar (back button, menu icons, etc.)
      iconTheme: IconThemeData(color: Colors.white),

      // titleTextStyle: Styling for the title text in the app bar
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // -------------------------------------------------------------------------
    // INPUT DECORATION THEME - Styling for text input fields
    // -------------------------------------------------------------------------
    // This defines how TextField and TextFormField widgets look.
    // Examples: search bars, login forms, text inputs.
    //
    // By defining this once, all text inputs in the app will have
    // consistent styling.
    inputDecorationTheme: InputDecorationTheme(
      // filled: Whether the input field has a background color
      filled: true,

      // fillColor: The background color of the input field
      // Colors.grey[100] is a very light grey
      fillColor: Colors.grey[100],

      // border: The default border style (used when not enabled or focused)
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30), // Rounded pill shape
        borderSide: BorderSide.none, // No visible border line
      ),

      // enabledBorder: Border style when the field is enabled but not focused
      // (Same as default border in this case)
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),

      // focusedBorder: Border style when user is actively typing in the field
      // This adds a colored border to show the field is active
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(
          color: Color(0xFFE63946), // Our brand red color
          width: 2, // 2 pixels thick
        ),
      ),
    ),

    // -------------------------------------------------------------------------
    // ELEVATED BUTTON THEME - Styling for raised buttons
    // -------------------------------------------------------------------------
    // ElevatedButtons are the main action buttons in Material Design.
    // They're called "elevated" because they traditionally had a shadow
    // to appear raised above the surface.
    //
    // This theme ensures all buttons in the app have consistent styling.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        // elevation: Shadow amount (0 = flat, modern style)
        elevation: 0,

        // padding: Space inside the button around the text
        // symmetric means same on left/right and same on top/bottom
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

        // shape: Rounded pill-shaped buttons
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  );

  // ===========================================================================
  // DARK THEME DEFINITION
  // ===========================================================================
  // This defines the complete look and feel of the app when in dark mode.
  //
  // WHY HAVE A DARK THEME?
  // Dark themes are popular because they:
  // - Reduce eye strain in low-light environments
  // - Save battery life on OLED/AMOLED screens
  // - Look modern and sleek
  // - Provide better contrast for some users
  // - Are preferred by many developers and users
  //
  // STRUCTURE MIRRORS LIGHT THEME:
  // Notice this has the same structure as lightTheme, but with different
  // colors. This consistency makes it easy to maintain both themes and
  // ensures the app looks good in both modes.
  // ===========================================================================
  static ThemeData darkTheme = ThemeData(
    // -------------------------------------------------------------------------
    // MATERIAL DESIGN 3 - Enabled
    // -------------------------------------------------------------------------
    // Same as light theme - we use Material 3 for both themes to ensure
    // consistent behavior and modern design principles.
    useMaterial3: true,

    // -------------------------------------------------------------------------
    // BRIGHTNESS - Dark mode
    // -------------------------------------------------------------------------
    // This tells Flutter this is a dark theme. Flutter uses this to:
    // - Choose appropriate default colors (light text on dark backgrounds)
    // - Automatically adjust widget colors for visibility
    // - Handle system UI elements (status bar, navigation bar)
    brightness: Brightness.dark,

    // -------------------------------------------------------------------------
    // COLOR SCHEME - Dark mode palette
    // -------------------------------------------------------------------------
    // Just like the light theme, we use ColorScheme.fromSeed to generate
    // a harmonious color palette. However, for dark mode we:
    // - Use slightly different seed colors (lighter red for better visibility)
    // - Set brightness to dark so generated colors work on dark backgrounds
    // - Use darker surface colors
    colorScheme: ColorScheme.fromSeed(
      // Slightly lighter red than light mode - better visibility on dark backgrounds
      seedColor: const Color(0xFFFF6B6B),

      // Specify this is for dark mode
      brightness: Brightness.dark,

      // Primary color - lighter red for visibility in dark mode
      primary: const Color(0xFFFF6B6B),

      // Secondary color - the darker red from light mode
      secondary: const Color(0xFFE63946),

      // Surface color - a dark blue-grey instead of pure black
      // Pure black (#000000) can be harsh on the eyes
      // This softer dark color is easier on the eyes and looks more premium
      surface: const Color(0xFF1E1E2E),
    ),

    // -------------------------------------------------------------------------
    // SCAFFOLD BACKGROUND COLOR
    // -------------------------------------------------------------------------
    // This is the background color for the entire screen (Scaffold widget).
    //
    // WHY SPECIFY THIS SEPARATELY?
    // While ColorScheme has a surface color, the scaffold uses a slightly
    // different shade to create visual depth. We use:
    // - 0xFF121212: A very dark grey (almost black but not quite)
    //
    // This is darker than our surface color (0xFF1E1E2E), which creates
    // a layered effect: Cards and components appear slightly elevated
    // above the background.
    scaffoldBackgroundColor: const Color(0xFF121212),

    // -------------------------------------------------------------------------
    // CARD THEME - Dark mode cards
    // -------------------------------------------------------------------------
    // Same structure as light mode, but with dark colors.
    cardTheme: CardThemeData(
      // No shadow (elevation 0) - modern flat design
      elevation: 0,

      // Rounded corners for soft, modern look
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      // Card background: Lighter than scaffold background (0xFF1E1E2E)
      // This creates visual separation - cards "float" above the dark background
      color: const Color(0xFF1E1E2E),
    ),

    // -------------------------------------------------------------------------
    // APP BAR THEME - Dark mode navigation bar
    // -------------------------------------------------------------------------
    // The top navigation bar styling for dark mode.
    appBarTheme: const AppBarTheme(
      // No shadow - modern flat design
      elevation: 0,

      // Center the title
      centerTitle: true,

      // Background color matches card color for visual consistency
      // This makes the app bar blend smoothly with the rest of the UI
      backgroundColor: Color(0xFF1E1E2E),

      // White icons for visibility on dark background
      iconTheme: IconThemeData(color: Colors.white),

      // White text for visibility on dark background
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // -------------------------------------------------------------------------
    // INPUT DECORATION THEME - Dark mode text inputs
    // -------------------------------------------------------------------------
    // Text input fields styled for dark mode.
    inputDecorationTheme: InputDecorationTheme(
      // Has background color
      filled: true,

      // Background matches card/surface color for consistency
      fillColor: const Color(0xFF1E1E2E),

      // Default border: rounded, no visible line
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),

      // Border when field is enabled but not focused
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),

      // Border when user is typing: shows our brand color
      // Note: We use the lighter red (0xFFFF6B6B) for better visibility
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(
          color: Color(0xFFFF6B6B), // Lighter red for dark mode
          width: 2,
        ),
      ),
    ),

    // -------------------------------------------------------------------------
    // ELEVATED BUTTON THEME - Dark mode buttons
    // -------------------------------------------------------------------------
    // Button styling for dark mode. Same as light mode - buttons will
    // automatically use appropriate colors from the ColorScheme.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        // Flat design (no shadow)
        elevation: 0,

        // Comfortable padding around button text
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

        // Rounded pill shape
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  );

  // ===========================================================================
  // HOW THEMES WORK IN THE APP
  // ===========================================================================
  // When you change the theme (by calling setThemeMode or toggleTheme):
  //
  // 1. The ThemeProvider's _themeMode variable changes
  // 2. notifyListeners() is called
  // 3. The MaterialApp (root of the app) is listening to ThemeProvider
  // 4. MaterialApp rebuilds and applies either lightTheme or darkTheme
  // 5. This change cascades down to EVERY widget in the app
  // 6. All widgets rebuild with new colors, styles, and appearance
  // 7. The change is INSTANT - the entire app updates in milliseconds
  //
  // This is the power of Flutter's reactive framework combined with the
  // Provider pattern - change one value at the top, and the entire app
  // responds automatically!
  // ===========================================================================
}
