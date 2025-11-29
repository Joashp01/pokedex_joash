import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_joash/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User should be created with required fields', () {
      final user = User(uid: 'test-uid-123');

      expect(user.uid, 'test-uid-123');
      expect(user.favoritePokemonIds, []);
    });

    test('User should be created with favorite Pokemon IDs', () {
      final user = User(
        uid: 'test-uid-123',
        favoritePokemonIds: [1, 25, 150],
      );

      expect(user.uid, 'test-uid-123');
      expect(user.favoritePokemonIds, [1, 25, 150]);
    });

    test('User.copyWith should create new instance with updated fields', () {
      final user = User(
        uid: 'test-uid-123',
        favoritePokemonIds: [1, 2, 3],
      );

      final updated = user.copyWith(
        favoritePokemonIds: [4, 5, 6],
      );

      expect(updated.uid, 'test-uid-123');
      expect(updated.favoritePokemonIds, [4, 5, 6]);
      expect(user.favoritePokemonIds, [1, 2, 3]); // Original unchanged
    });

    test('User.copyWith should keep original values if not specified', () {
      final user = User(
        uid: 'test-uid-123',
        favoritePokemonIds: [1, 2, 3],
      );

      final updated = user.copyWith();

      expect(updated.uid, 'test-uid-123');
      expect(updated.favoritePokemonIds, [1, 2, 3]);
    });

    test('User.toMap should convert to Map correctly', () {
      final user = User(
        uid: 'test-uid-123',
        favoritePokemonIds: [1, 25, 150],
      );

      final map = user.toMap();

      expect(map['uid'], 'test-uid-123');
      expect(map['favoritePokemonIds'], [1, 25, 150]);
    });

    test('User.fromMap should create User from Map correctly', () {
      final map = {
        'uid': 'test-uid-123',
        'favoritePokemonIds': [1, 25, 150],
      };

      final user = User.fromMap(map, 'test-uid-123');

      expect(user.uid, 'test-uid-123');
      expect(user.favoritePokemonIds, [1, 25, 150]);
    });

    test('User.fromMap should handle missing favoritePokemonIds', () {
      final map = {
        'uid': 'test-uid-123',
      };

      final user = User.fromMap(map, 'test-uid-123');

      expect(user.uid, 'test-uid-123');
      expect(user.favoritePokemonIds, []);
    });

    test('User.fromMap should handle null favoritePokemonIds', () {
      final map = {
        'uid': 'test-uid-123',
        'favoritePokemonIds': null,
      };

      final user = User.fromMap(map, 'test-uid-123');

      expect(user.uid, 'test-uid-123');
      expect(user.favoritePokemonIds, []);
    });
  });
}
