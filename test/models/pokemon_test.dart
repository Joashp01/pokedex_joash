import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_joash/models/pokemon.dart';

void main() {
  group('Pokemon Model Tests', () {
    test('Pokemon.fromJson should parse JSON correctly', () {
      final json = {
        'id': 1,
        'name': 'bulbasaur',
        'height': 7,
        'weight': 69,
        'types': [
          {
            'type': {'name': 'grass'}
          },
          {
            'type': {'name': 'poison'}
          }
        ],
        'stats': [
          {
            'base_stat': 45,
            'stat': {'name': 'hp'}
          }
        ],
        'sprites': {
          'front_default': 'https://example.com/bulbasaur.png',
          'other': {
            'official-artwork': {
              'front_default': 'https://example.com/artwork.png'
            }
          }
        }
      };

      final pokemon = Pokemon.fromJson(json);

      expect(pokemon.id, 1);
      expect(pokemon.name, 'bulbasaur');
      expect(pokemon.height, 7);
      expect(pokemon.weight, 69);
      expect(pokemon.types, ['grass', 'poison']);
      expect(pokemon.stats.length, 1);
      expect(pokemon.imageUrl, 'https://example.com/artwork.png');
    });

    test('Pokemon.copyWith should create new instance with updated fields', () {
      final pokemon = Pokemon(
        id: 1,
        name: 'bulbasaur',
        imageUrl: 'url',
        types: ['grass'],
        stats: [],
        height: 7,
        weight: 69,
      );

      final updated = pokemon.copyWith(
        description: 'A grass type pokemon',
        abilities: ['overgrow'],
      );

      expect(updated.id, 1);
      expect(updated.name, 'bulbasaur');
      expect(updated.description, 'A grass type pokemon');
      expect(updated.abilities, ['overgrow']);
    });
  });

  group('PokemonStat Tests', () {
    test('PokemonStat.fromJson should parse JSON correctly', () {
      final json = {
        'base_stat': 45,
        'stat': {'name': 'hp'}
      };

      final stat = PokemonStat.fromJson(json);

      expect(stat.baseStat, 45);
      expect(stat.name, 'hp');
    });

    test('PokemonStat.displayName should return correct display names', () {
      final stats = {
        'hp': 'HP',
        'attack': 'Attack',
        'defense': 'Defense',
        'special-attack': 'Sp. Atk',
        'special-defense': 'Sp. Def',
        'speed': 'Speed',
      };

      stats.forEach((name, expectedDisplay) {
        final stat = PokemonStat(name: name, baseStat: 50);
        expect(stat.displayName, expectedDisplay);
      });
    });
  });

  group('PokemonListItem Tests', () {
    test('PokemonListItem.fromJson should parse JSON correctly', () {
      final json = {
        'name': 'bulbasaur',
        'url': 'https://pokeapi.co/api/v2/pokemon/1/',
        'types': ['grass', 'poison']
      };

      final item = PokemonListItem.fromJson(json);

      expect(item.name, 'bulbasaur');
      expect(item.url, 'https://pokeapi.co/api/v2/pokemon/1/');
      expect(item.types, ['grass', 'poison']);
    });

    test('PokemonListItem.id should extract ID from URL', () {
      final item = PokemonListItem(
        name: 'bulbasaur',
        url: 'https://pokeapi.co/api/v2/pokemon/1/',
      );

      expect(item.id, 1);
    });

    test('PokemonListItem.id should handle different URL formats', () {
      final item = PokemonListItem(
        name: 'charizard',
        url: 'https://pokeapi.co/api/v2/pokemon/6',
      );

      expect(item.id, 6);
    });
  });

  group('EvolutionStage Tests', () {
    test('EvolutionStage.displayName should capitalize first letter', () {
      final stage = EvolutionStage(
        id: 1,
        name: 'bulbasaur',
        imageUrl: 'url',
      );

      expect(stage.displayName, 'Bulbasaur');
    });

    test('EvolutionStage should handle optional fields', () {
      final stage = EvolutionStage(
        id: 1,
        name: 'bulbasaur',
        imageUrl: 'url',
        minLevel: 16,
        trigger: 'level-up',
      );

      expect(stage.minLevel, 16);
      expect(stage.trigger, 'level-up');
    });
  });
}
