import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_joash/controllers/pokemon_controller.dart';
import 'package:pokedex_joash/models/pokemon.dart';
import 'package:pokedex_joash/providers/theme_provider.dart';
import 'package:pokedex_joash/views/home/poke_details.dart';

import 'pokemon_detail_view_widget_test.mocks.dart';

// Generate mocks using Mockito's code generation
@GenerateMocks([PokemonController, ThemeProvider])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PokemonDetailView Widget Tests', () {
    late MockPokemonController mockController;
    late MockThemeProvider mockThemeProvider;

    setUp(() {
      mockController = MockPokemonController();
      mockThemeProvider = MockThemeProvider();

      // Set up default mock behaviors
      when(mockController.isLoading).thenReturn(false);
      when(mockController.error).thenReturn(null);
      when(mockController.selectedPokemon).thenReturn(null);
      when(mockThemeProvider.isDarkMode).thenReturn(false);
      when(mockThemeProvider.themeMode).thenReturn(ThemeMode.light);
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
        ],
        child: const MaterialApp(
          home: PokemonDetailView(pokemonId: 25),
        ),
      );
    }

    testWidgets('should display loading indicator when loading',
        (WidgetTester tester) async {
      when(mockController.isLoading).thenReturn(true);
      when(mockController.selectedPokemon).thenReturn(null);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should display error message when error occurs',
        (WidgetTester tester) async {
      when(mockController.isLoading).thenReturn(false);
      when(mockController.error).thenReturn('Failed to load Pokemon');
      when(mockController.selectedPokemon).thenReturn(null);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.textContaining('Error:'), findsOneWidget);
      expect(find.textContaining('Failed to load Pokemon'), findsOneWidget);
    });

    testWidgets('should display Pokemon details when loaded',
        (WidgetTester tester) async {
      final mockPokemon = Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png',
        types: ['electric'],
        height: 4,
        weight: 60,
        abilities: ['static', 'lightning-rod'],
        stats: [
          PokemonStat(name: 'hp', baseStat: 35),
          PokemonStat(name: 'attack', baseStat: 55),
          PokemonStat(name: 'defense', baseStat: 40),
          PokemonStat(name: 'special-attack', baseStat: 50),
          PokemonStat(name: 'special-defense', baseStat: 50),
          PokemonStat(name: 'speed', baseStat: 90),
        ],
        description: 'When several of these Pokémon gather, their electricity could build and cause lightning storms.',
        evolutionChain: [],
      );

      when(mockController.isLoading).thenReturn(false);
      when(mockController.error).thenReturn(null);
      when(mockController.selectedPokemon).thenReturn(mockPokemon);
      when(mockController.isFavorite(25)).thenReturn(false);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Pikachu'), findsOneWidget);
      expect(find.text('#025'), findsOneWidget);
      expect(find.text('ELECTRIC'), findsOneWidget);
      expect(find.text('0.4 m'), findsOneWidget);
      expect(find.text('6.0 kg'), findsOneWidget);
    });

    testWidgets('should display Pokemon stats correctly',
        (WidgetTester tester) async {
      final mockPokemon = Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: 'https://example.com/pikachu.png',
        types: ['electric'],
        height: 4,
        weight: 60,
        abilities: ['static'],
        stats: [
          PokemonStat(name: 'hp', baseStat: 35),
          PokemonStat(name: 'attack', baseStat: 55),
          PokemonStat(name: 'defense', baseStat: 40),
        ],
        description: 'A mouse Pokemon',
        evolutionChain: [],
      );

      when(mockController.isLoading).thenReturn(false);
      when(mockController.selectedPokemon).thenReturn(mockPokemon);
      when(mockController.isFavorite(25)).thenReturn(false);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Base Stats'), findsOneWidget);
      expect(find.text('HP'), findsOneWidget);
      expect(find.text('Attack'), findsOneWidget);
      expect(find.text('Defense'), findsOneWidget);
      expect(find.text('35'), findsOneWidget);
      expect(find.text('55'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
    });

    testWidgets('should display Pokemon abilities',
        (WidgetTester tester) async {
      final mockPokemon = Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: 'https://example.com/pikachu.png',
        types: ['electric'],
        height: 4,
        weight: 60,
        abilities: ['static', 'lightning-rod'],
        stats: [PokemonStat(name: 'hp', baseStat: 35)],
        description: 'A mouse Pokemon',
        evolutionChain: [],
      );

      when(mockController.isLoading).thenReturn(false);
      when(mockController.selectedPokemon).thenReturn(mockPokemon);
      when(mockController.isFavorite(25)).thenReturn(false);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Abilities'), findsOneWidget);
      expect(find.text('Static'), findsOneWidget);
      expect(find.text('Lightning Rod'), findsOneWidget);
    });

    testWidgets('should toggle favorite when favorite button is tapped',
        (WidgetTester tester) async {
      final mockPokemon = Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: 'https://example.com/pikachu.png',
        types: ['electric'],
        height: 4,
        weight: 60,
        abilities: ['static'],
        stats: [PokemonStat(name: 'hp', baseStat: 35)],
        description: 'A mouse Pokemon',
        evolutionChain: [],
      );

      when(mockController.isLoading).thenReturn(false);
      when(mockController.selectedPokemon).thenReturn(mockPokemon);
      when(mockController.isFavorite(25)).thenReturn(false);
      when(mockController.toggleFavorite(25)).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Find and tap the favorite button
      final favoriteButton = find.widgetWithIcon(IconButton, Icons.favorite_border);
      expect(favoriteButton, findsOneWidget);

      await tester.tap(favoriteButton);
      await tester.pump();

      // Verify that toggleFavorite was called
      verify(mockController.toggleFavorite(25)).called(1);
    });

    testWidgets('should display evolution chain when available',
        (WidgetTester tester) async {
      final mockPokemon = Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: 'https://example.com/pikachu.png',
        types: ['electric'],
        height: 4,
        weight: 60,
        abilities: ['static'],
        stats: [PokemonStat(name: 'hp', baseStat: 35)],
        description: 'A mouse Pokemon',
        evolutionChain: [
          EvolutionStage(
            id: 172,
            name: 'pichu',
            imageUrl: 'https://example.com/pichu.png',
          ),
          EvolutionStage(
            id: 25,
            name: 'pikachu',
            imageUrl: 'https://example.com/pikachu.png',
            minLevel: 15,
          ),
          EvolutionStage(
            id: 26,
            name: 'raichu',
            imageUrl: 'https://example.com/raichu.png',
          ),
        ],
      );

      when(mockController.isLoading).thenReturn(false);
      when(mockController.selectedPokemon).thenReturn(mockPokemon);
      when(mockController.isFavorite(25)).thenReturn(false);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Evolution Chain'), findsOneWidget);
      expect(find.text('Pichu'), findsOneWidget);
      expect(find.text('Pikachu'), findsAtLeastNWidgets(2)); // One in header, one in evolution chain
      expect(find.text('Raichu'), findsOneWidget);
    });

    testWidgets('should use correct theme colors in dark mode',
        (WidgetTester tester) async {
      final mockPokemon = Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: 'https://example.com/pikachu.png',
        types: ['electric'],
        height: 4,
        weight: 60,
        abilities: ['static'],
        stats: [PokemonStat(name: 'hp', baseStat: 35)],
        description: 'A mouse Pokemon',
        evolutionChain: [],
      );

      when(mockController.isLoading).thenReturn(false);
      when(mockController.selectedPokemon).thenReturn(mockPokemon);
      when(mockController.isFavorite(25)).thenReturn(false);

      await tester.pumpWidget(createTestWidget(isDark: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify dark mode is applied by checking for key widgets
      expect(find.text('Pikachu'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Verify isDarkMode was checked
      verify(mockThemeProvider.isDarkMode).called(greaterThan(0));
    });

    testWidgets('should have Hero animation with correct tag',
        (WidgetTester tester) async {
      final mockPokemon = Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: 'https://example.com/pikachu.png',
        types: ['electric'],
        height: 4,
        weight: 60,
        abilities: ['static'],
        stats: [PokemonStat(name: 'hp', baseStat: 35)],
        description: 'A mouse Pokemon',
        evolutionChain: [],
      );

      when(mockController.isLoading).thenReturn(false);
      when(mockController.selectedPokemon).thenReturn(mockPokemon);
      when(mockController.isFavorite(25)).thenReturn(false);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final heroFinder = find.byType(Hero);
      expect(heroFinder, findsOneWidget);

      final Hero hero = tester.widget(heroFinder);
      expect(hero.tag, 'pokemon-25');
    });

    testWidgets('should display description when available',
        (WidgetTester tester) async {
      final mockPokemon = Pokemon(
        id: 25,
        name: 'pikachu',
        imageUrl: 'https://example.com/pikachu.png',
        types: ['electric'],
        height: 4,
        weight: 60,
        abilities: ['static'],
        stats: [PokemonStat(name: 'hp', baseStat: 35)],
        description: 'This Pokemon has electricity-storing pouches on its cheeks.',
        evolutionChain: [],
      );

      when(mockController.isLoading).thenReturn(false);
      when(mockController.selectedPokemon).thenReturn(mockPokemon);
      when(mockController.isFavorite(25)).thenReturn(false);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(
        find.text('This Pokemon has electricity-storing pouches on its cheeks.'),
        findsOneWidget,
      );
    });
  });
}
