// Import dart:convert library - allows us to convert JSON data to Dart objects
import 'dart:convert';
// Import http package - allows us to make internet requests to APIs
import 'package:http/http.dart' as http;
// Import our Pokemon model to structure the data we receive
import 'package:pokedex_joash/models/pokemon.dart';
// Export EvolutionStage so other files can use it when they import this service
export 'package:pokedex_joash/models/pokemon.dart' show EvolutionStage;

// This class holds the response when we fetch a page of Pokemon
// WHY: When fetching Pokemon, we need to know not just the list, but also
// how many total Pokemon exist and if there are more pages to load
class PaginatedPokemonResponse {
  final List<PokemonListItem> results;  // The actual list of Pokemon on this page
  final int totalCount;  // Total number of Pokemon in the entire database
  final bool hasMore;  // True if there are more Pokemon to load (for pagination)

  // Constructor - this is called when creating a new PaginatedPokemonResponse object
  // The 'required' keyword means these parameters must be provided
  PaginatedPokemonResponse({
    required this.results,
    required this.totalCount,
    required this.hasMore,
    });
}

// This class handles all API calls to the Pokemon API
// WHY: By centralizing all API calls in one service, we keep our code organized
// and make it easy to update API logic in one place
class ApiService {

// The base URL for all Pokemon API requests
// const means this value never changes - it's a constant throughout the app
static const String baseUrl = 'https://pokeapi.co/api/v2';

// Fetches a paginated list of Pokemon from the API
// WHAT: Gets a specific "page" of Pokemon (like page 1, page 2, etc.)
// WHY: Loading all Pokemon at once would be slow, so we load them in chunks
//
// Parameters:
//   limit: How many Pokemon to fetch (default is 20)
//   offset: Where to start fetching from (0 = start from beginning)
//
// Future means this function returns a value in the future (after waiting)
// async means this function can wait for slow operations (like internet requests)
Future<PaginatedPokemonResponse> fetchPokemonList({
  int limit = 20,
  int offset = 0,
}) async{

  // Build the complete URL with query parameters
  // Example: https://pokeapi.co/api/v2/pokemon?limit=20&offset=0
  final url = Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset');

  // Make an HTTP GET request to the API
  // await means "wait for this to complete before moving to the next line"
  final response = await http.get(url);

  // Check if the request was successful
  // Status code 200 means "OK" - the request worked
  if (response.statusCode == 200){

    // Parse the JSON response body into a Dart Map
    // json.decode converts the text response into a data structure we can use
    final Map<String,dynamic> data = json.decode(response.body);

    // Extract specific pieces of data from the response
    final int totalCount = data['count'];  // Total Pokemon in database
    final List<dynamic> results = data['results'];  // Array of Pokemon objects

    // Convert each JSON object into a PokemonListItem object
    // .map() applies a function to each item in the list
    // .toList() converts the result back into a list
    final pokemonList = results.map((item) => PokemonListItem.fromJson(item)).toList();

    // Check if there's a 'next' URL (means there are more pages to load)
    final String? nextUrl = data['next'];

    // Return the structured response with all the data we extracted
    return PaginatedPokemonResponse(
      results: pokemonList,
      totalCount: totalCount,
      hasMore: nextUrl != null,  // If nextUrl exists, there are more Pokemon

    );

  } else {
    // If the request failed, throw an error
    // This will stop the function and tell the caller something went wrong
    throw Exception('Failed to load pokemon list');

  }

}

// Private cache variable to store all Pokemon once they're fetched
// The underscore (_) makes this variable private to this file
// The question mark (?) means it can be null (empty) initially
// WHY: We cache (save) all Pokemon so we don't have to fetch them every time we search
List<PokemonListItem>? _allPokemons;

// Searches for Pokemon by name
// WHAT: Filters through all Pokemon to find ones matching the search query
// WHY: Users want to quickly find specific Pokemon without scrolling
//
// Parameters:
//   query: The search text (like "pika" to find Pikachu)
//   limit: Maximum number of results to return (default 20)
Future<List<PokemonListItem>> searchPokemon(String query, {int limit = 20})
async{
  // The ??= operator means "if _allPokemons is null, fetch all Pokemon"
  // This ensures we only fetch all Pokemon once, then reuse the cached data
  _allPokemons ??= await _fetchAllPokemons();

  // Convert the search query to lowercase for case-insensitive search
  // This way "PIKA", "pika", and "Pika" all match "Pikachu"
  final lowerQuery = query.toLowerCase();

  // Filter the cached Pokemon list
  // .where() filters items that match a condition
  // .contains() checks if the Pokemon name includes the search text
  // .take() limits the results to the specified number
  // .toList() converts the filtered results into a list
  final filtered = _allPokemons!
      .where((pokemon) => pokemon.name.toLowerCase().contains(lowerQuery))
      .take(limit)
      .toList();

  return filtered;
}

// Private helper function to fetch all Pokemon from the API
// The underscore (_) means this is only used within this file
// WHAT: Fetches up to 2000 Pokemon at once for searching
// WHY: Having all Pokemon loaded lets us search through them quickly
Future<List<PokemonListItem>> _fetchAllPokemons() async {
  // Request a large limit (2000) to get all Pokemon in one request
  final url = Uri.parse('$baseUrl/pokemon?limit=2000&offset=0');

  // Wait for the API response
  final response = await http.get(url);

  // Check if request was successful
  if (response.statusCode == 200){
    // Parse JSON response
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> results = data['results'];

    // Convert each JSON object to a PokemonListItem and return the list
    return results.map((json) => PokemonListItem.fromJson(json)).toList();
  } else{
    // If fetch fails, throw an error
    throw Exception('Failed to load pokemon list');
  }

}

// Fetches detailed information about a specific Pokemon
// WHAT: Gets all the details about one Pokemon (stats, abilities, types, etc.)
// WHY: The list view only shows basic info, but the detail page needs everything
//
// Parameters:
//   idOrName: Can be either a Pokemon ID (like 25) or name (like "pikachu")
//   dynamic type means it accepts any type of data
Future<Pokemon> fetchPokemonDetails(dynamic idOrName) async{
  // First get the raw JSON data
  final data = await fetchPokemonDetailsRaw(idOrName);

  // Then convert it to a Pokemon object using the model's fromJson method
  return Pokemon.fromJson(data);

}

// Fetches Pokemon details as raw JSON data (Map)
// WHAT: Gets the same data as fetchPokemonDetails, but doesn't convert it to a Pokemon object
// WHY: Sometimes we just need the raw data without creating an object
//
// Returns: A Map (like a dictionary) with all the Pokemon data
Future<Map<String, dynamic>> fetchPokemonDetailsRaw(dynamic idOrName) async{
  // Build URL with the Pokemon ID or name
  // Example: https://pokeapi.co/api/v2/pokemon/25 or .../pokemon/pikachu
  final url = Uri.parse('$baseUrl/pokemon/$idOrName');

  // Make the HTTP GET request and wait for response
  final response = await http.get(url);

  // Check if successful
  if (response.statusCode == 200){
    // Decode and return the JSON data as a Map
    return json.decode(response.body);
  } else{
    // If failed, throw an error
    throw Exception('Failed to load pokemon details');

  }

}

// Fetches the description/biography text for a Pokemon
// WHAT: Gets the Pokedex entry description (the story text about the Pokemon)
// WHY: Users want to read about what the Pokemon is and does
//
// Returns: String with description, or null if not found
// The ? after String means it can return null (nothing) if there's no description
Future<String?> fetchPokemonDescription(int pokemonId) async {
  // try-catch block - if something goes wrong, we handle the error gracefully
  // instead of crashing the app
  try {
    // Pokemon descriptions come from a different API endpoint: pokemon-species
    final url = Uri.parse('$baseUrl/pokemon-species/$pokemonId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Parse the JSON response
      final data = json.decode(response.body);

      // The API returns descriptions in multiple languages
      // We need to find the English version
      final flavorTextEntries = data['flavor_text_entries'] as List;

      // Loop through each description entry
      for (var entry in flavorTextEntries) {
        // Check if this entry is in English
        if (entry['language']['name'] == 'en') {
          // Get the description text
          String text = entry['flavor_text'];

          // Clean up the text by removing newlines (\n) and form feeds (\f)
          // WHY: These special characters make the text look messy on screen
          text = text.replaceAll('\n', ' ').replaceAll('\f', ' ');

          return text;
        }
      }
    }
    // If no English description found, return null
    return null;
  } catch (e) {
    // If any error occurs (network issue, parsing error, etc.), return null
    // WHY: Better to show no description than to crash the app
    return null;
  }
}

// Fetches the evolution chain for a Pokemon
// WHAT: Gets all the evolution stages (like Charmander -> Charmeleon -> Charizard)
// WHY: Users want to see how Pokemon evolve and what they evolve into
//
// This is complex because it requires TWO API calls:
// 1. First, get the species data (which contains a link to the evolution chain)
// 2. Then, fetch the actual evolution chain data
//
// Returns: List of EvolutionStage objects, or empty list if there's an error
Future<List<EvolutionStage>> fetchEvolutionChain(int pokemonId) async {
  // try-catch to handle any errors gracefully
  try {
    // STEP 1: Get the Pokemon species data
    // WHY: The evolution chain URL is stored in the species data, not the main Pokemon data
    final speciesUrl = Uri.parse('$baseUrl/pokemon-species/$pokemonId');
    final speciesResponse = await http.get(speciesUrl);

    // If the species request failed, return empty list
    if (speciesResponse.statusCode != 200) {
      return [];
    }

    // Parse the species data
    final speciesData = json.decode(speciesResponse.body);

    // Extract the evolution chain URL from the species data
    // This URL points to another API endpoint with the evolution information
    final evolutionChainUrl = speciesData['evolution_chain']['url'] as String;

    // STEP 2: Fetch the evolution chain data using the URL we just got
    final evolutionsResponse = await http.get(Uri.parse(evolutionChainUrl));

    // If the evolution request failed, return empty list
    if (evolutionsResponse.statusCode != 200) {
      return [];
    }

    // Parse the evolution chain data
    final evolutionsData = json.decode(evolutionsResponse.body);

    // The evolution data is nested in a 'chain' object
    // This chain contains all evolution stages in a tree structure
    final chain = evolutionsData['chain'];

    // Create an empty list to store the evolution stages
    List<EvolutionStage> stages = [];

    // Parse the complex chain structure into our simple list
    // This helper function will fill the 'stages' list
    _parseEvolutionChain(chain, stages);

    return stages;
  } catch (e) {
    // If anything goes wrong, return an empty list instead of crashing
    return [];
  }
}

// Private helper function to parse the evolution chain data
// WHAT: Recursively processes the nested evolution chain structure
// WHY: The API returns evolution data in a complex nested format (tree structure)
//      We need to flatten it into a simple list
//
// This is a RECURSIVE function - it calls itself to handle multiple evolution paths
// Example: Eevee evolves into 8 different Pokemon, so we need to process each branch
//
// Parameters:
//   chain: The current evolution chain node (Map with Pokemon data)
//   stages: The list we're filling with evolution stages (passed by reference)
void _parseEvolutionChain(
    Map<String, dynamic> chain, List<EvolutionStage> stages) {

  // Extract the Pokemon species name from the chain data
  final species = chain['species']['name'] as String;

  // Extract the species URL - we need this to get the Pokemon ID
  final speciesUrl = chain['species']['url'] as String;

  // Parse the URL to extract the Pokemon ID
  // The URL looks like: ".../pokemon-species/25/"
  // We split it into segments and take the last number
  final uri = Uri.parse(speciesUrl);
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  final id = int.parse(segments.last);

  // Variables to store evolution requirements
  // ? means they can be null (not all evolutions have these)
  int? minLevel;     // Level needed to evolve (like level 16)
  String? trigger;   // How to evolve (level-up, trade, stone, etc.)

  // Get evolution details (how this Pokemon evolves)
  final evolutionDetails = chain['evolution_details'] as List;
  if (evolutionDetails.isNotEmpty) {
    // Get the first evolution method (some Pokemon have multiple ways to evolve)
    final details = evolutionDetails[0];
    minLevel = details['min_level'];  // Can be null if evolution doesn't need a level
    trigger = details['trigger']['name'];  // The evolution trigger type
  }

  // Construct the image URL for this Pokemon
  // GitHub hosts all Pokemon sprites (images) in a consistent format
  final imageUrl =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

  // Create an EvolutionStage object and add it to our stages list
  stages.add(EvolutionStage(
    name: species,
    id: id,
    imageUrl: imageUrl,
    minLevel: minLevel,
    trigger: trigger,
  ));

  // Check if this Pokemon evolves into others
  // 'evolves_to' is a list because some Pokemon have multiple evolution paths
  final evolvesTo = chain['evolves_to'] as List;

  // RECURSIVE CALL: For each evolution path, call this function again
  // This handles chains like: Charmander -> Charmeleon -> Charizard
  // The function calls itself to process Charmeleon, then calls itself again for Charizard
  for (var evolution in evolvesTo) {
    _parseEvolutionChain(evolution, stages);
  }
}
}
