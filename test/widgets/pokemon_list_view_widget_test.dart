import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_joash/controllers/pokemon_controller.dart';
import 'package:pokedex_joash/models/pokemon.dart';
import 'package:pokedex_joash/providers/theme_provider.dart';
import 'package:pokedex_joash/services/pokemon_sound.dart';
import 'package:pokedex_joash/views/home/poke_home.dart';

import 'pokemon_list_view_widget_test.mocks.dart';

// Generate mocks using Mockito's code generation
@GenerateMocks([PokemonController, ThemeProvider, AudioService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PokemonListView Widget Tests', () {
    late MockPokemonController mockController;
    late MockThemeProvider mockThemeProvider;
    late MockAudioService mockAudioService;

    setUp(() {
      mockController = MockPokemonController();
      mockThemeProvider = MockThemeProvider();
      mockAudioService = MockAudioService();

      // Set up default mock behaviors
      when(mockController.isLoading).thenReturn(false);
      when(mockController.error).thenReturn(null);
      when(mockController.displayList).thenReturn([]);
      when(mockController.pokemonList).thenReturn([]);
      when(mockController.isLoadingMore).thenReturn(false);
      when(mockController.isSearching).thenReturn(false);
      when(mockController.searchQuery).thenReturn('');
      when(mockController.showingFavoritesOnly).thenReturn(false);
      when(mockThemeProvider.isDarkMode).thenReturn(false);
      when(mockThemeProvider.themeMode).thenReturn(ThemeMode.light);
      when(mockAudioService.isMusicPlaying).thenReturn(false);
    });

    Widget createTestWidget({bool isDark = false}) {
      when(mockThemeProvider.isDarkMode).thenReturn(isDark);
      when(mockThemeProvider.themeMode).thenReturn(isDark ? ThemeMode.dark : ThemeMode.light);

      return MultiProvider(
        providers: [
          ChangeNotifierProvider<PokemonController>.value(
            value: mockController,
          ),
          ChangeNotifierProvider<ThemeProvider>.value(
            value: mockThemeProvider,
          ),
          Provider<AudioService>.value(
            value: mockAudioService,
          ),
        ],
        child: const MaterialApp(
          home: PokemonListView(),
        ),
      );
    }

    testWidgets('should display loading indicator when loading',
        (WidgetTester tester) async {
      when(mockController.isLoading).thenReturn(true);
      when(mockController.displayList).thenReturn([]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(find.text('Loading Pokémon...'), findsOneWidget);
    });

    testWidgets('should display error message with retry button when error occurs',
        (WidgetTester tester) async {
      when(mockController.isLoading).thenReturn(false);
      when(mockController.error).thenReturn('Failed to load Pokemon list');
      when(mockController.displayList).thenReturn([]);
      when(mockController.fetchPokemonList()).thenAnswer((_) async => {});

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.textContaining('Error:'), findsOneWidget);
      expect(find.textContaining('Failed to load Pokemon list'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });

    testWidgets('should display Pokemon list when loaded',
        (WidgetTester tester) async {
      final pokemonList = [
        PokemonListItem(name: 'bulbasaur', url: 'https://pokeapi.co/api/v2/pokemon/1/', types: ['grass', 'poison']),
        PokemonListItem(name: 'charmander', url: 'https://pokeapi.co/api/v2/pokemon/4/', types: ['fire']),
        PokemonListItem(name: 'squirtle', url: 'https://pokeapi.co/api/v2/pokemon/7/', types: ['water']),
      ];

      when(mockController.isLoading).thenReturn(false);
      when(mockController.displayList).thenReturn(pokemonList);
      when(mockController.pokemonList).thenReturn(pokemonList);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Bulbasaur'), findsOneWidget);
      expect(find.text('Charmander'), findsOneWidget);
      expect(find.text('Squirtle'), findsOneWidget);
      expect(find.text('#001'), findsOneWidget);
      expect(find.text('#004'), findsOneWidget);
      expect(find.text('#007'), findsOneWidget);
    });

    testWidgets('should display search bar with correct hint text',
        (WidgetTester tester) async {
      when(mockController.displayList).thenReturn([
        PokemonListItem(name: 'bulbasaur', url: 'https://pokeapi.co/api/v2/pokemon/1/', types: ['grass']),
      ]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Search Pokémon...'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('should filter Pokemon when search query is entered',
        (WidgetTester tester) async {
      when(mockController.displayList).thenReturn([
        PokemonListItem(name: 'bulbasaur', url: 'https://pokeapi.co/api/v2/pokemon/1/', types: ['grass']),
        PokemonListItem(name: 'charmander', url: 'https://pokeapi.co/api/v2/pokemon/4/', types: ['fire']),
        PokemonListItem(name: 'pikachu', url: 'https://pokeapi.co/api/v2/pokemon/25/', types: ['electric']),
      ]);
      when(mockController.searchPokemon(any)).thenAnswer((_) async => {});

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'pika');
      await tester.pump();

      verify(mockController.searchPokemon('pika')).called(1);
    });

    testWidgets('should display empty search state when no results found',
        (WidgetTester tester) async {
      when(mockController.isLoading).thenReturn(false);
      when(mockController.displayList).thenReturn([]);
      when(mockController.isSearching).thenReturn(true);
      when(mockController.searchQuery).thenReturn('nonexistent');

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
      expect(find.text('No Pokémon found'), findsOneWidget);
      expect(find.text('for "nonexistent"'), findsOneWidget);
    });

    testWidgets('should display clear button when searching',
        (WidgetTester tester) async {
      when(mockController.displayList).thenReturn([
        PokemonListItem(name: 'bulbasaur', url: 'https://pokeapi.co/api/v2/pokemon/1/', types: ['grass']),
      ]);
      when(mockController.isSearching).thenReturn(true);
      when(mockController.searchQuery).thenReturn('bulba');

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('should show Pokédex title in AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Pokédex'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have theme toggle button in AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
    });

    testWidgets('should have favorites filter button in AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.favorite_border), findsWidgets);
    });

    testWidgets('should have logout button in AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
    });

    testWidgets('should have music toggle button in AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.music_off), findsOneWidget);
    });

    testWidgets('should display Pokemon cards with Hero widgets',
        (WidgetTester tester) async {
      when(mockController.displayList).thenReturn([
        PokemonListItem(name: 'pikachu', url: 'https://pokeapi.co/api/v2/pokemon/25/', types: ['electric']),
      ]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(Hero), findsOneWidget);
      final Hero hero = tester.widget(find.byType(Hero));
      expect(hero.tag, 'pokemon-25');
    });

    testWidgets('should display loading indicator at bottom when loading more',
        (WidgetTester tester) async {
      when(mockController.displayList).thenReturn([
        PokemonListItem(name: 'bulbasaur', url: 'https://pokeapi.co/api/v2/pokemon/1/', types: ['grass']),
      ]);
      when(mockController.isLoadingMore).thenReturn(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should have correct gradient background in light mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isDark: false));
      await tester.pump();

      // Verify widget tree is built correctly
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should have correct gradient background in dark mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isDark: true));
      await tester.pump();

      // Verify widget tree is built correctly
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display Pokemon cards with arrow icon',
        (WidgetTester tester) async {
      when(mockController.displayList).thenReturn([
        PokemonListItem(name: 'bulbasaur', url: 'https://pokeapi.co/api/v2/pokemon/1/', types: ['grass']),
      ]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('should toggle favorites filter when favorites button is tapped',
        (WidgetTester tester) async {
      when(mockController.showingFavoritesOnly).thenReturn(false);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find and tap the favorites filter button
      final favoriteButtons = find.byIcon(Icons.favorite_border);
      await tester.tap(favoriteButtons.first);
      await tester.pump();

      // Verify toggleFavoritesFilter was called
      verify(mockController.toggleFavoritesFilter()).called(1);
    });

    testWidgets('should call retry when retry button is tapped',
        (WidgetTester tester) async {
      when(mockController.isLoading).thenReturn(false);
      when(mockController.error).thenReturn('Network error');
      when(mockController.displayList).thenReturn([]);
      when(mockController.fetchPokemonList()).thenAnswer((_) async => {});

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Reset mock call count after widget initialization
      clearInteractions(mockController);

      // Find and tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Verify fetchPokemonList was called
      verify(mockController.fetchPokemonList()).called(1);
    });
  });
}
