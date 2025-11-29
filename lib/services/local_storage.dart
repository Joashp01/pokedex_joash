import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon.dart';

class LocalStorageService {
  static const String _favoritedPokemonKey = 'favorited_pokemon_cache';

  Future<void> saveFavoritedPokemon(List<PokemonListItem> pokemon) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = pokemon.map((p) => {
      'name': p.name,
      'url': p.url,
      'types': p.types,
    }).toList();

    await prefs.setString(_favoritedPokemonKey, json.encode(jsonList));
  }

  Future<List<PokemonListItem>> getFavoritedPokemon() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritedPokemonKey);

    if (jsonString == null) {
      return [];
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => PokemonListItem(
      name: json['name'],
      url: json['url'],
      types: List<String>.from(json['types'] ?? []),
    )).toList();
  }

  Future<void> clearFavoritedPokemon() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritedPokemonKey);
  }
}
