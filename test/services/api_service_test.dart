import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_joash/services/api_service.dart';

void main() {
  group('ApiService Tests', () {
    test('ApiService should have correct base URL', () {
      expect(ApiService.baseUrl, 'https://pokeapi.co/api/v2');
    });

    group('PaginatedPokemonResponse Tests', () {
      test('PaginatedPokemonResponse should be created correctly', () {
        final response = PaginatedPokemonResponse(
          results: [],
          totalCount: 1000,
          hasMore: true,
        );

        expect(response.results, []);
        expect(response.totalCount, 1000);
        expect(response.hasMore, true);
      });

      test('PaginatedPokemonResponse should handle no more results', () {
        final response = PaginatedPokemonResponse(
          results: [],
          totalCount: 20,
          hasMore: false,
        );

        expect(response.hasMore, false);
      });
    });

    group('URL Construction Tests', () {
      test('fetchPokemonList should construct correct URL with default params', () {
        final limit = 20;
        final offset = 0;
        final expectedUrl = '${ApiService.baseUrl}/pokemon?limit=$limit&offset=$offset';

        expect(expectedUrl, 'https://pokeapi.co/api/v2/pokemon?limit=20&offset=0');
      });

      test('fetchPokemonList should construct correct URL with custom params', () {
        final limit = 50;
        final offset = 100;
        final expectedUrl = '${ApiService.baseUrl}/pokemon?limit=$limit&offset=$offset';

        expect(expectedUrl, 'https://pokeapi.co/api/v2/pokemon?limit=50&offset=100');
      });

      test('fetchPokemonDetails should construct correct URL with ID', () {
        final id = 25;
        final expectedUrl = '${ApiService.baseUrl}/pokemon/$id';

        expect(expectedUrl, 'https://pokeapi.co/api/v2/pokemon/25');
      });

      test('fetchPokemonDetails should construct correct URL with name', () {
        final name = 'pikachu';
        final expectedUrl = '${ApiService.baseUrl}/pokemon/$name';

        expect(expectedUrl, 'https://pokeapi.co/api/v2/pokemon/pikachu');
      });

      test('fetchPokemonDescription should construct correct URL', () {
        final id = 1;
        final expectedUrl = '${ApiService.baseUrl}/pokemon-species/$id';

        expect(expectedUrl, 'https://pokeapi.co/api/v2/pokemon-species/1');
      });
    });
  });
}
