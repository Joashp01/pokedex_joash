 import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_joash/models/pokemon.dart';
import 'package:pokedex_joash/models/user.dart';

void main() {
  group('Pokemon Model Logic Tests', () {
    test('Pokemon ID extraction from URL works correctly', () {
      final item = PokemonListItem(
        name: 'bulbasaur',
        url: 'https://pokeapi.co/api/v2/pokemon/1/',
      );
      expect(item.id, 1);
    });

    test('User favorite pokemon logic works', () {
      final user = User(uid: 'test-uid', favoritePokemonIds: [1, 25, 150]);
      expect(user.favoritePokemonIds.contains(1), true);
      expect(user.favoritePokemonIds.contains(2), false);
    });
  });

  group('Pokemon List Filtering Tests', () {
    test('Filter favorites should work correctly', () {
      final user = User(uid: 'test-uid', favoritePokemonIds: [1, 25]);
      final allPokemon = [
        PokemonListItem(name: 'bulbasaur', url: 'https://pokeapi.co/api/v2/pokemon/1/'),
        PokemonListItem(name: 'ivysaur', url: 'https://pokeapi.co/api/v2/pokemon/2/'),
        PokemonListItem(name: 'pikachu', url: 'https://pokeapi.co/api/v2/pokemon/25/'),
      ];

      final favorites = allPokemon.where((p) => user.favoritePokemonIds.contains(p.id)).toList();

      expect(favorites.length, 2);
      expect(favorites[0].name, 'bulbasaur');
      expect(favorites[1].name, 'pikachu');
    });

    test('Search functionality logic', () {
      final allPokemon = [
        PokemonListItem(name: 'bulbasaur', url: 'https://pokeapi.co/api/v2/pokemon/1/'),
        PokemonListItem(name: 'ivysaur', url: 'https://pokeapi.co/api/v2/pokemon/2/'),
        PokemonListItem(name: 'pikachu', url: 'https://pokeapi.co/api/v2/pokemon/25/'),
      ];

      final query = 'pika';
      final filtered = allPokemon.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();

      expect(filtered.length, 1);
      expect(filtered.first.name, 'pikachu');
    });
  });

  group('Pokemon Stats Display Tests', () {
    test('PokemonStat displayName formatting', () {
      final hpStat = PokemonStat(name: 'hp', baseStat: 45);
      expect(hpStat.displayName, 'HP');

      final specialAttack = PokemonStat(name: 'special-attack', baseStat: 65);
      expect(specialAttack.displayName, 'Sp. Atk');
    });

    test('Pokemon type list handling', () {
      final pokemon = Pokemon(
        id: 1,
        name: 'bulbasaur',
        imageUrl: 'url',
        types: ['grass', 'poison'],
        stats: [],
        height: 7,
        weight: 69,
      );

      expect(pokemon.types.length, 2);
      expect(pokemon.types.contains('grass'), true);
      expect(pokemon.types.contains('poison'), true);
    });
  });
}
