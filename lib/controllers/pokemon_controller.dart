
import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/api_service.dart';

// ========================================================================
// WHAT IS THIS CLASS?
// ========================================================================
// PokemonController is a STATE MANAGEMENT class that controls all the
// Pokemon data in our app. Think of it as a "brain" that stores data
// and tells the UI when to update.
//
// WHY EXTEND ChangeNotifier?
// ChangeNotifier is a built-in Flutter class that implements the
// Observer pattern. When we call notifyListeners(), it tells all
// widgets listening to this controller: "Hey! My data changed, rebuild yourself!"
//
// This is the foundation of the Provider pattern in Flutter.
// ========================================================================
class PokemonController extends ChangeNotifier {
  // ======================================================================
  // DEPENDENCY INJECTION
  // ======================================================================
  // Create an instance of ApiService to fetch data from the Pokemon API
  // We make it 'final' because we never need to replace it
  final ApiService _apiService = ApiService();

  // ======================================================================
  // PRIVATE STATE VARIABLES
  // ======================================================================
  // WHY PRIVATE (_underscore)?
  // In Dart, variables starting with _ are private to this file.
  // We use private variables with public getters to control HOW our data
  // is accessed. This is called ENCAPSULATION.
  //
  // Benefits:
  // 1. Outside code can READ but not directly MODIFY our data
  // 2. We control when notifyListeners() is called
  // 3. We can add validation or logic when data changes
  // ======================================================================

  // Stores the list of all Pokemon fetched from the API
  // This is our main data storage for the Pokemon list screen
  List<PokemonListItem> _pokemonList = [];

  // Stores the currently selected Pokemon with full details
  // The '?' means it can be null (no Pokemon selected yet)
  Pokemon? _selectedPokemon;

  // Tracks if we're currently loading data (shows loading spinner in UI)
  bool _isLoading = false;

  // Stores any error message if something goes wrong
  // String? means it can be null (no error) or contain an error message
  String? _error;

  // ======================================================================
  // PAGINATION STATE VARIABLES
  // ======================================================================
  // WHAT IS PAGINATION?
  // Instead of loading ALL Pokemon at once (which would be slow),
  // we load them in small "pages" (like chapters in a book).
  // When you scroll to the bottom, we load the next page.
  //
  // WHY USE PAGINATION?
  // 1. Faster initial load time (only load 20 Pokemon instead of 1000+)
  // 2. Less memory usage
  // 3. Better user experience (app feels snappier)
  // ======================================================================

  // Tracks WHERE we are in the complete list of Pokemon
  // Example: 0 = start, 20 = skip first 20, 40 = skip first 40, etc.
  int _currentOffset = 0;

  // How many Pokemon to fetch in each request (like page size)
  // 'static const' means this value is the same for ALL instances
  // and never changes during the app's lifetime
  static const int _pageSize = 20;

  // Tracks if there are MORE Pokemon to load
  // When this is false, we've reached the end of the list
  bool _hasMore = true;

  // Tracks if we're currently loading the NEXT page of Pokemon
  // Different from _isLoading because this is for loading MORE, not initial load
  bool _isLoadingMore = false;

  // ======================================================================
  // SEARCH STATE VARIABLES
  // ======================================================================
  // These variables manage the search functionality
  // ======================================================================

  // Stores what the user typed in the search box
  String _searchQuery = '';

  // Stores Pokemon that match the search query
  List<PokemonListItem> _searchResults = [];

  // Tracks if user is currently in "search mode"
  // When true, we show search results instead of the full list
  bool _isSearching = false;

  // ======================================================================
  // PUBLIC GETTERS
  // ======================================================================
  // WHAT ARE GETTERS?
  // Getters allow outside code to READ our private variables without
  // being able to MODIFY them directly.
  //
  // WHY USE GETTERS?
  // Instead of: controller._pokemonList (direct access - NOT allowed)
  // We do: controller.pokemonList (through getter - SAFE)
  //
  // This ensures that ONLY this controller can change the data, and
  // it will always call notifyListeners() when it does.
  // ======================================================================

  // Provides read-only access to the full Pokemon list
  List<PokemonListItem> get pokemonList => _pokemonList;

  // Provides read-only access to the selected Pokemon
  Pokemon? get selectedPokemon => _selectedPokemon;

  // Tells UI if data is currently being loaded (show spinner or not)
  bool get isLoading => _isLoading;

  // Provides any error message to display to the user
  String? get error => _error;

  // Tells UI if there are more Pokemon to load (for infinite scroll)
  bool get hasMore => _hasMore;

  // Tells UI if we're currently loading more Pokemon (for bottom loader)
  bool get isLoadingMore => _isLoadingMore;

  // Provides the current search query text
  String get searchQuery => _searchQuery;

  // Provides the search results list
  List<PokemonListItem> get searchResults => _searchResults;

  // Tells UI if user is in search mode
  bool get isSearching => _isSearching;

  // SMART GETTER: Automatically returns the correct list to display
  // If searching: returns search results
  // If not searching: returns full Pokemon list
  // This simplifies the UI code - it just asks for "displayList"
  List<PokemonListItem> get displayList =>
      _isSearching ? _searchResults : _pokemonList;

  // ======================================================================
  // METHOD: fetchPokemonList
  // ======================================================================
  // PURPOSE: Fetches the FIRST page of Pokemon from the API
  // WHEN CALLED: When the app starts or when user refreshes the list
  //
  // ASYNC/AWAIT EXPLANATION:
  // - 'Future<void>' means this function runs asynchronously (in background)
  //   and doesn't return a value when done
  // - 'async' keyword marks this as an asynchronous function
  // - 'await' pauses execution until the API call finishes
  //   (without freezing the UI)
  //
  // WHY ASYNC?
  // API calls take time (network request). We don't want to freeze the app
  // while waiting. Instead, the app continues running, and when data arrives,
  // this function resumes.
  // ======================================================================
  Future<void> fetchPokemonList() async {
    // STEP 1: Reset all state for a fresh start
    _isLoading = true; // Show loading spinner in UI
    _error = null; // Clear any previous errors
    _currentOffset = 0; // Reset pagination to start from beginning
    _pokemonList = []; // Clear the old list

    // NOTIFY UI: "I changed the state, please rebuild!"
    // This will hide the old list and show a loading spinner
    notifyListeners();

    // STEP 2: Try to fetch data (might fail due to network issues)
    try {
      // Wait for API to return the first page of Pokemon
      // limit: how many to fetch (20)
      // offset: where to start (0 = from the beginning)
      final response =
          await _apiService.fetchPokemonList(limit: _pageSize, offset: 0);

      // STEP 3: If successful, save the data
      _pokemonList = response.results; // Save the Pokemon list
      _hasMore = response.hasMore; // Check if there are more pages
      _currentOffset = _pageSize; // Next time, start from position 20
      _isLoading = false; // Stop showing loading spinner

      // NOTIFY UI: "Data is ready, rebuild with new Pokemon!"
      notifyListeners();
    } catch (e) {
      // STEP 4: If something went wrong, save the error
      _error = e.toString(); // Convert error to readable text
      _isLoading = false; // Stop showing loading spinner

      // NOTIFY UI: "Show the error message to the user"
      notifyListeners();
    }
  }

  // ======================================================================
  // METHOD: loadMorePokemon
  // ======================================================================
  // PURPOSE: Loads the NEXT page of Pokemon (infinite scroll)
  // WHEN CALLED: When user scrolls to the bottom of the Pokemon list
  //
  // PAGINATION LOGIC EXPLAINED:
  // Imagine Pokemon as a book with many pages. Each page has 20 Pokemon.
  // - Page 1: Pokemon 1-20 (offset = 0)
  // - Page 2: Pokemon 21-40 (offset = 20)
  // - Page 3: Pokemon 41-60 (offset = 40)
  // The offset tells the API "skip this many Pokemon and give me the next 20"
  // ======================================================================
  Future<void> loadMorePokemon() async {
    // GUARD CLAUSES: Don't load more if...
    // 1. We're already loading more (prevent duplicate requests)
    // 2. There's no more data to load (we reached the end)
    // 3. User is searching (search has its own list, don't mix them)
    if (_isLoadingMore || !_hasMore || _isSearching) return;

    // STEP 1: Mark that we're loading more
    _isLoadingMore = true;
    // NOTIFY UI: "Show a small loader at the bottom of the list"
    notifyListeners();

    // STEP 2: Try to fetch the next page
    try {
      // Request next page of Pokemon starting from _currentOffset
      // Example: If _currentOffset = 20, get Pokemon 21-40
      final response = await _apiService.fetchPokemonList(
        limit: _pageSize,
        offset: _currentOffset,
      );

      // STEP 3: Add new Pokemon to the EXISTING list (don't replace it!)
      _pokemonList.addAll(response.results); // Append to end of list

      // Check if there are even more pages after this one
      _hasMore = response.hasMore;

      // Move the offset forward for the next page
      // Example: was 20, now becomes 40 (20 + 20)
      _currentOffset += _pageSize;

      // Done loading
      _isLoadingMore = false;

      // NOTIFY UI: "I added more Pokemon, rebuild the list!"
      notifyListeners();
    } catch (e) {
      // STEP 4: If fetch fails, just stop loading
      // (We don't show error here because the user still has the
      // previous Pokemon to look at. They can try again by scrolling.)
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ======================================================================
  // METHOD: searchPokemon
  // ======================================================================
  // PURPOSE: Searches for Pokemon by name
  // WHEN CALLED: Every time the user types in the search box
  //
  // SEARCH LOGIC EXPLAINED:
  // When searching, we switch to "search mode" which:
  // 1. Shows search results instead of the full list
  // 2. Disables pagination (search results are separate)
  // 3. Returns to normal mode when search is cleared
  //
  // PARAMETERS:
  // - query: The text the user typed (e.g., "pika", "char", "bulb")
  // ======================================================================
  Future<void> searchPokemon(String query) async {
    // Save what the user typed
    _searchQuery = query;

    // EARLY RETURN: If search box is empty, exit search mode
    if (query.trim().isEmpty) {
      _isSearching = false; // Back to normal mode
      _searchResults = []; // Clear old search results
      // NOTIFY UI: "Stop showing search results, show full list again"
      notifyListeners();
      return; // Stop here, don't search for nothing
    }

    // STEP 1: Enter search mode and start loading
    _isSearching = true; // Tell UI we're in search mode
    _isLoading = true; // Show loading spinner
    // NOTIFY UI: "Show loading spinner, we're searching"
    notifyListeners();

    // STEP 2: Try to search for Pokemon
    try {
      // Call API to search for Pokemon matching the query
      // limit: 50 means show up to 50 results (more than pagination)
      _searchResults = await _apiService.searchPokemon(query, limit: 50);

      // STEP 3: Search successful
      _isLoading = false; // Stop loading spinner
      // NOTIFY UI: "Here are the search results, display them!"
      notifyListeners();
    } catch (e) {
      // STEP 4: Search failed (network error, API error, etc.)
      _error = e.toString(); // Save error message
      _isLoading = false; // Stop loading spinner
      // NOTIFY UI: "Show error message to user"
      notifyListeners();
    }
  }

  // ======================================================================
  // METHOD: clearSearch
  // ======================================================================
  // PURPOSE: Exits search mode and returns to showing the full Pokemon list
  // WHEN CALLED: When user clears the search box or clicks a "clear" button
  //
  // This is like pressing the "X" button in a search bar - it resets
  // everything back to normal browsing mode.
  // ======================================================================
  void clearSearch() {
    // Reset all search-related state
    _searchQuery = ''; // Clear the search text
    _searchResults = []; // Clear the search results
    _isSearching = false; // Exit search mode

    // NOTIFY UI: "Stop showing search, go back to the full list"
    // This will make the UI show the paginated Pokemon list again
    notifyListeners();
  }

  // ======================================================================
  // METHOD: selectPokemon
  // ======================================================================
  // PURPOSE: Fetches DETAILED information about a specific Pokemon
  // WHEN CALLED: When user taps on a Pokemon card to see its details
  //
  // WHY IS THIS COMPLEX?
  // Getting full Pokemon details requires MULTIPLE API calls:
  // 1. Basic details (name, stats, types)
  // 2. Description (the Pokedex entry text)
  // 3. Evolution chain (what it evolves from/into)
  // We combine all this data into one complete Pokemon object.
  //
  // PARAMETERS:
  // - pokemonId: The ID number of the Pokemon (e.g., 25 for Pikachu)
  // ======================================================================
  Future<void> selectPokemon(int pokemonId) async {
    // STEP 1: Reset state for loading new Pokemon details
    _isLoading = true; // Show loading spinner
    _error = null; // Clear any previous errors
    _selectedPokemon = null; // Clear previous Pokemon details

    // NOTIFY UI: "Show loading screen on details page"
    notifyListeners();

    // STEP 2: Try to fetch all the data we need
    try {
      // Get the basic Pokemon data (stats, types, height, weight, etc.)
      final response = await _apiService.fetchPokemonDetailsRaw(pokemonId);

      // Convert the raw JSON response into a Pokemon object
      Pokemon pokemon = Pokemon.fromJson(response);

      // Extract abilities from the response
      // (response['abilities'] is a complex nested structure, we simplify it)
      List<String> abilities = (response['abilities'] as List)
          .map((abilityData) => abilityData['ability']['name'] as String)
          .toList();

      // PARALLEL API CALLS: Fetch description and evolution chain at the same time
      // Future.wait() runs multiple async operations simultaneously (faster!)
      // Instead of: fetch description -> WAIT -> fetch evolution (slow)
      // We do: fetch BOTH at the same time (fast!)
      final results = await Future.wait([
        _apiService.fetchPokemonDescription(pokemonId),
        _apiService.fetchEvolutionChain(pokemonId),
      ]);

      // Extract results from the parallel calls
      // results[0] = description, results[1] = evolution chain
      String? description = results[0] as String?;
      List<EvolutionStage> evolutionChain = results[1] as List<EvolutionStage>;

      // STEP 3: Combine all data into one complete Pokemon object
      // copyWith() creates a copy of the Pokemon with additional fields
      _selectedPokemon = pokemon.copyWith(
        description: description,
        abilities: abilities,
        evolutionChain: evolutionChain,
      );

      // STEP 4: Done loading
      _isLoading = false;

      // NOTIFY UI: "Pokemon details are ready, show them!"
      notifyListeners();
    } catch (e) {
      // STEP 5: If anything failed, show error
      _error = e.toString();
      _isLoading = false;

      // NOTIFY UI: "Show error message on details page"
      notifyListeners();
    }
  }

  // ======================================================================
  // METHOD: clearSelectedPokemon
  // ======================================================================
  // PURPOSE: Clears the currently selected Pokemon details
  // WHEN CALLED: When user navigates back from the details page
  //
  // WHY DO THIS?
  // When you leave the details page, we don't need to keep that data
  // in memory anymore. Clearing it:
  // 1. Saves memory
  // 2. Ensures next time you open details, you see fresh loading state
  // 3. Prevents showing old Pokemon data when navigating
  // ======================================================================
  void clearSelectedPokemon() {
    _selectedPokemon = null; // Clear the detailed Pokemon data

    // NOTIFY UI: "Pokemon details cleared, update any listening widgets"
    notifyListeners();
  }
}

// ========================================================================
// HOW THIS ALL WORKS TOGETHER (The Big Picture)
// ========================================================================
//
// 1. SETUP: In your main app, you wrap widgets with a Provider:
//    ChangeNotifierProvider(
//      create: (_) => PokemonController(),
//      child: YourApp(),
//    )
//
// 2. LISTENING: Widgets listen to this controller:
//    final controller = Provider.of<PokemonController>(context);
//    or
//    Consumer<PokemonController>(
//      builder: (context, controller, child) => ...
//    )
//
// 3. DATA FLOW:
//    User Action -> Controller Method Called -> State Changes ->
//    notifyListeners() -> Listening Widgets Rebuild -> UI Updates
//
// 4. EXAMPLE:
//    User scrolls to bottom ->
//    loadMorePokemon() is called ->
//    _pokemonList gets more items added ->
//    notifyListeners() is called ->
//    Pokemon list widget rebuilds ->
//    User sees new Pokemon!
//
// WHY IS THIS BETTER THAN setState()?
// - State is separate from UI (cleaner code)
// - Multiple widgets can listen to the same controller
// - Easier to test (can test controller without UI)
// - Easier to maintain (all logic in one place)
//
// KEY TAKEAWAY:
// This controller is like a TV remote - it controls what shows on screen
// (the state), and whenever you press a button (call a method), it tells
// the TV (UI) to update by calling notifyListeners().
// ========================================================================
