import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedex_joash/models/pokemon.dart';
export 'package:pokedex_joash/models/pokemon.dart' show EvolutionStage;

class PaginatedPokemonResponse {
  final List<PokemonListItem> results;
  final int totalCount;
  final bool hasMore;

  PaginatedPokemonResponse({
    required this.results,
    required this.totalCount,
    required this.hasMore,
  });
}

class ApiService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<PaginatedPokemonResponse> fetchPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    final url = Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      final int totalCount = data['count'];

      final pokemonListItems = results
          .map(
            (item) => PokemonListItem(
              name: item['name'],
              url: item['url'],
              types: [],
            ),
          )
          .toList();

      final String? nextUrl = data['next'];
      final bool hasMore = nextUrl != null;

      return PaginatedPokemonResponse(
        results: pokemonListItems,
        totalCount: totalCount,
        hasMore: hasMore,
      );
    } else {
      throw Exception('Failed to load pokemon list');
    }
  }

  Future<List<PokemonListItem>> searchPokemon(
    String query, {
    int limit = 20,
  }) async {
    final lowerQuery = query.toLowerCase().trim();

    if (lowerQuery.isEmpty) {
      return [];
    }

    try {
      final url = Uri.parse('$baseUrl/pokemon/$lowerQuery');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final types = (data['types'] as List)
            .map((typeData) => typeData['type']['name'] as String)
            .toList();

        return [
          PokemonListItem(
            name: data['name'],
            url: '$baseUrl/pokemon/${data['id']}/',
            types: types,
          ),
        ];
      }
    } catch (_) {}

    _allPokemons ??= await _fetchAllPokemons();

    final filtered = _allPokemons!
        .where((pokemon) => pokemon.name.toLowerCase().contains(lowerQuery))
        .take(limit)
        .toList();

    return filtered;
  }

  List<PokemonListItem>? _allPokemons;

  Future<List<PokemonListItem>> _fetchAllPokemons() async {
    final url = Uri.parse('$baseUrl/pokemon?limit=2000&offset=0');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];

      return results
          .map(
            (json) => PokemonListItem(
              name: json['name'],
              url: json['url'],
              types: [],
            ),
          )
          .toList();
    } else {
      throw Exception('Failed to load pokemon list');
    }
  }

  Future<PokemonListItem> fetchPokemonDetails(String url, String name) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load pokemon details');
    }

    final detailData = json.decode(response.body);
    final types = (detailData['types'] as List)
        .map((typeData) => typeData['type']['name'] as String)
        .toList();

    return PokemonListItem(name: name, url: url, types: types);
  }

  Future<Map<String, dynamic>> fetchPokemonDetailsRaw(dynamic idOrName) async {
    final url = Uri.parse('$baseUrl/pokemon/$idOrName');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load pokemon details');
    }
  }

  Future<String?> fetchPokemonDescription(int pokemonId) async {
    try {
      final url = Uri.parse('$baseUrl/pokemon-species/$pokemonId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final flavorTextEntries = data['flavor_text_entries'] as List;

        for (var entry in flavorTextEntries) {
          if (entry['language']['name'] == 'en') {
            String text = entry['flavor_text'];

            text = text.replaceAll('\n', ' ').replaceAll('\f', ' ');

            return text;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<EvolutionStage>> fetchEvolutionChain(int pokemonId) async {
    try {
      final speciesUrl = Uri.parse('$baseUrl/pokemon-species/$pokemonId');
      final speciesResponse = await http.get(speciesUrl);

      if (speciesResponse.statusCode != 200) {
        return [];
      }

      final speciesData = json.decode(speciesResponse.body);

      final evolutionChainUrl = speciesData['evolution_chain']['url'] as String;

      final evolutionsResponse = await http.get(Uri.parse(evolutionChainUrl));

      if (evolutionsResponse.statusCode != 200) {
        return [];
      }

      final evolutionsData = json.decode(evolutionsResponse.body);

      final chain = evolutionsData['chain'];

      List<EvolutionStage> stages = [];

      _parseEvolutionChain(chain, stages);

      return stages;
    } catch (e) {
      return [];
    }
  }

  void _parseEvolutionChain(
    Map<String, dynamic> chain,
    List<EvolutionStage> stages,
  ) {
    final species = chain['species']['name'] as String;

    final speciesUrl = chain['species']['url'] as String;

    final uri = Uri.parse(speciesUrl);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final id = int.parse(segments.last);

    int? minLevel;
    String? trigger;

    final evolutionDetails = chain['evolution_details'] as List;
    if (evolutionDetails.isNotEmpty) {
      final details = evolutionDetails[0];
      minLevel = details['min_level'];
      trigger = details['trigger']['name'];
    }

    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

    stages.add(
      EvolutionStage(
        name: species,
        id: id,
        imageUrl: imageUrl,
        minLevel: minLevel,
        trigger: trigger,
      ),
    );

    final evolvesTo = chain['evolves_to'] as List;

    for (var evolution in evolvesTo) {
      _parseEvolutionChain(evolution, stages);
    }
  }
}
