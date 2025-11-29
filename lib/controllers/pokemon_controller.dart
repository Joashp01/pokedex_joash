
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/pokemon.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth.dart';
import '../services/local_storage.dart';


class PokemonController extends ChangeNotifier {

  final ApiService _apiService = ApiService();

  final AuthService _authService = AuthService();

  final LocalStorageService _localStorage = LocalStorageService();

  final Connectivity _connectivity = Connectivity();

  bool _isOffline = false;

  User? _currentUser;

  List<PokemonListItem> _pokemonList = [];

  Pokemon? _selectedPokemon;

  bool _isLoading = false;

  String? _error;


  int _currentOffset = 0;

  static const int _pageSize = 20;

  bool _hasMore = true;

  bool _isLoadingMore = false;

  String _searchQuery = '';

  List<PokemonListItem> _searchResults = [];

  bool _isSearching = false;

  bool _showingFavoritesOnly = false;

  List<PokemonListItem> _favoritedPokemonCache = [];

  List<PokemonListItem> get pokemonList => _pokemonList;

  Pokemon? get selectedPokemon => _selectedPokemon;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasMore => _hasMore;

  bool get isLoadingMore => _isLoadingMore;

  String get searchQuery => _searchQuery;

  List<PokemonListItem> get searchResults => _searchResults;

  bool get isSearching => _isSearching;

  bool get showingFavoritesOnly => _showingFavoritesOnly;

  User? get currentUser => _currentUser;

  bool get isOffline => _isOffline;

  List<PokemonListItem> get displayList {
    if (_isSearching) return _searchResults;
    if (_showingFavoritesOnly && _currentUser != null) {
      final favoritedIds = _currentUser!.favoritePokemonIds;
      final loadedFavorites = _pokemonList
          .where((pokemon) => favoritedIds.contains(pokemon.id))
          .toList();

      final allFavorites = <int, PokemonListItem>{};
      for (var pokemon in _favoritedPokemonCache) {
        allFavorites[pokemon.id] = pokemon;
      }
      for (var pokemon in loadedFavorites) {
        allFavorites[pokemon.id] = pokemon;
      }

      return allFavorites.values.toList();
    }
    return _pokemonList;
  }
  void setUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> initializeConnectivity() async {
    await _checkConnectivity();

    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    final wasOffline = _isOffline;
    _isOffline = connectivityResults.contains(ConnectivityResult.none);

    if (wasOffline && !_isOffline && _pokemonList.isEmpty) {
      await fetchPokemonList();
    }

    notifyListeners();
  }

  Future<void> loadUserData() async {
    _currentUser = await _authService.getCurrentUserData();

    if (_currentUser != null && _currentUser!.favoritePokemonIds.isNotEmpty) {
      if (_isOffline) {
        await _loadFavoritedPokemonFromCache();
      } else {
        await _loadFavoritedPokemon();
      }
    }

    notifyListeners();
  }

  Future<void> _loadFavoritedPokemonFromCache() async {
    final cached = await _localStorage.getFavoritedPokemon();
    _favoritedPokemonCache = cached;
  }

  Future<void> _loadFavoritedPokemon() async {
    if (_currentUser == null) return;

    final favoritedIds = _currentUser!.favoritePokemonIds;
    final loadedIds = _pokemonList.map((p) => p.id).toSet();

    final unloadedFavorites = favoritedIds.where((id) => !loadedIds.contains(id)).toList();

    if (unloadedFavorites.isEmpty) return;

    _favoritedPokemonCache = [];

    for (final pokemonId in unloadedFavorites) {
      try {
        final data = await _apiService.fetchPokemonDetailsRaw(pokemonId);
        final types = (data['types'] as List)
            .map((typeData) => typeData['type']['name'] as String)
            .toList();

        final pokemonItem = PokemonListItem(
          name: data['name'],
          url: 'https://pokeapi.co/api/v2/pokemon/$pokemonId/',
          types: types,
        );

        _favoritedPokemonCache.add(pokemonItem);
      } catch (e) {
        continue;
      }
    }

    await _saveFavoritedPokemonToCache();
  }

  Future<void> _saveFavoritedPokemonToCache() async {
    if (_currentUser == null) return;

    final favoritedIds = _currentUser!.favoritePokemonIds;
    final allFavorites = <int, PokemonListItem>{};

    for (var pokemon in _favoritedPokemonCache) {
      if (favoritedIds.contains(pokemon.id)) {
        allFavorites[pokemon.id] = pokemon;
      }
    }

    for (var pokemon in _pokemonList) {
      if (favoritedIds.contains(pokemon.id)) {
        allFavorites[pokemon.id] = pokemon;
      }
    }

    await _localStorage.saveFavoritedPokemon(allFavorites.values.toList());
  }

  bool isFavorite(int pokemonId) {
    if (_currentUser == null) return false;
    return _currentUser!.favoritePokemonIds.contains(pokemonId);
  }

  Future<bool> toggleFavorite(int pokemonId) async {
    if (_currentUser == null) return false;

    final isFav = isFavorite(pokemonId);
    final success = await _authService.toggleFavorite(pokemonId, isFav);

    if (success) {
      await loadUserData();
      await _saveFavoritedPokemonToCache();
    }

    return success;
  }

  void toggleFavoritesFilter() {
    _showingFavoritesOnly = !_showingFavoritesOnly;
    notifyListeners();
  }

  Future<void> fetchPokemonList() async {
    if (_isOffline) {
      _error = 'No internet connection. Showing favorites only.';
      _isLoading = false;
      _showingFavoritesOnly = true;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _currentOffset = 0;
    _pokemonList = [];

    notifyListeners();

    try {
      final response =
          await _apiService.fetchPokemonList(limit: _pageSize, offset: 0);

      _pokemonList = response.results;
      _hasMore = response.hasMore;
      _currentOffset = _pageSize;
      _isLoading = false;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> loadMorePokemon() async {
    if (_isLoadingMore || !_hasMore || _isSearching) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _apiService.fetchPokemonList(
        limit: _pageSize,
        offset: _currentOffset,
      );

      _pokemonList.addAll(response.results);

      _hasMore = response.hasMore;

      _currentOffset += _pageSize;

      _isLoadingMore = false;

      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> searchPokemon(String query) async {
    _searchQuery = query;

    if (query.trim().isEmpty) {
      _isSearching = false;
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchPokemon(query, limit: 50);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _isSearching = false;

    notifyListeners();
  }

  Future<void> selectPokemon(int pokemonId) async {
    _isLoading = true;
    _error = null;
    _selectedPokemon = null;

    notifyListeners();

    try {
      final response = await _apiService.fetchPokemonDetailsRaw(pokemonId);

      Pokemon pokemon = Pokemon.fromJson(response);

      List<String> abilities = (response['abilities'] as List)
          .map((abilityData) => abilityData['ability']['name'] as String)
          .toList();

      final results = await Future.wait([
        _apiService.fetchPokemonDescription(pokemonId),
        _apiService.fetchEvolutionChain(pokemonId),
      ]);

      String? description = results[0] as String?;
      List<EvolutionStage> evolutionChain = results[1] as List<EvolutionStage>;

      _selectedPokemon = pokemon.copyWith(
        description: description,
        abilities: abilities,
        evolutionChain: evolutionChain,
      );

      _isLoading = false;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;

      notifyListeners();
    }
  }

  void clearSelectedPokemon() {
    _selectedPokemon = null;

    notifyListeners();
  }
}
