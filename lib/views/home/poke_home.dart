import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_joash/controllers/pokemon_controller.dart';
import 'package:pokedex_joash/models/pokemon.dart';
import 'package:pokedex_joash/providers/theme_provider.dart';
import 'package:pokedex_joash/services/pokemon_sound.dart';
import 'package:pokedex_joash/services/auth.dart';
import 'package:pokedex_joash/widgets/pokemon_search_bar.dart';
import 'package:pokedex_joash/widgets/pokemon_list_card.dart';
import 'poke_details.dart';

class PokemonListView extends StatefulWidget {
  const PokemonListView({super.key});

  @override
  State<PokemonListView> createState() => _PokemonListViewState();
}

class _PokemonListViewState extends State<PokemonListView> {
  final TextEditingController _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    Future.microtask(() {
      if (mounted) {
        context.read<PokemonController>().fetchPokemonList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<PokemonController>().loadMorePokemon();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 1200 ? 1200.0 : screenWidth;

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: const Text(
          'Pokédex',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1E1E2E).withValues(alpha: 0.85),
                      const Color(0xFF2A2A3E).withValues(alpha: 0.85),
                    ]
                  : [
                      const Color(0xFFE63946).withValues(alpha: 0.9),
                      const Color(0xFFD62839).withValues(alpha: 0.9),
                    ],
            ),
          ),
        ),
        actions: [
          Consumer<AudioService>(
            builder: (context, audioService, child) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: audioService.isMusicPlaying
                      ? (isDark
                            ? const Color(0xFFFFCB05).withValues(alpha: 0.3)
                            : Colors.yellow.withValues(alpha: 0.3))
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    audioService.isMusicPlaying
                        ? Icons.music_note
                        : Icons.music_off,
                    size: 22,
                  ),
                  tooltip: audioService.isMusicPlaying
                      ? 'Pause theme song'
                      : 'Play theme song',
                  onPressed: () {
                    if (audioService.isMusicPlaying) {
                      audioService.pauseThemeSong();
                    } else {
                      audioService.resumeThemeSong();
                    }
                    setState(() {});
                  },
                ),
              );
            },
          ),
          Consumer<PokemonController>(
            builder: (context, controller, child) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.showingFavoritesOnly
                      ? (isDark
                            ? const Color(0xFFFF6B6B).withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.4))
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    controller.showingFavoritesOnly
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 22,
                  ),
                  tooltip: controller.showingFavoritesOnly
                      ? 'Show all Pokemon'
                      : 'Show favorites only',
                  onPressed: () {
                    controller.toggleFavoritesFilter();
                  },
                ),
              );
            },
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 22,
              ),
              tooltip: 'Toggle theme',
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, size: 22),
              tooltip: 'Logout',
              onPressed: () async {
                final AuthService auth = AuthService();
                await auth.signOut();
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1E1E2E), const Color(0xFF121212)]
                : [const Color(0xFFF8F9FA), const Color(0xFFE8EAED)],
          ),
        ),

        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Consumer<PokemonController>(
              builder: (context, controller, child) {
                return Column(
                  children: [
                    const SizedBox(height: 100),
                    if (controller.isOffline)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.orange.shade900.withValues(alpha: 0.3)
                              : Colors.orange.shade100,
                          border: Border.all(
                            color: isDark
                                ? Colors.orange.shade700
                                : Colors.orange.shade300,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              color: isDark
                                  ? Colors.orange.shade300
                                  : Colors.orange.shade900,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Offline Mode - Showing favorites only',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.orange.shade200
                                      : Colors.orange.shade900,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    PokemonSearchBar(
                      controller: _searchController,
                      isDark: isDark,
                      isSearching: controller.isSearching,
                      onChanged: (query) => controller.searchPokemon(query),
                      onClear: () {
                        _searchController.clear();
                        controller.clearSearch();
                      },
                    ),
                    Expanded(child: _buildBody(controller, isDark)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(PokemonController controller, bool isDark) {
    final displayList = controller.displayList;

    if (controller.isLoading && displayList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: isDark ? const Color(0xFFFF6B6B) : const Color(0xFFE63946),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading Pokémon...',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (controller.error != null && displayList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: isDark ? Colors.red[300] : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${controller.error}',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.fetchPokemonList(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFFE63946),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (controller.isSearching &&
        displayList.isEmpty &&
        !controller.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80,
              color: isDark ? Colors.grey[700] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Pokémon found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'for "${controller.searchQuery}"',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      itemCount: displayList.length + (controller.isLoadingMore ? 1 : 0),

      itemBuilder: (context, index) {
        if (index == displayList.length) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(
                color: isDark
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFFE63946),
              ),
            ),
          );
        }

        final pokemon = displayList[index];
        return PokemonListCard(
          pokemon: pokemon,
          isDark: isDark,
          onTap: () => _onPokemonTap(pokemon),
        );
      },
    );
  }

  void _onPokemonTap(PokemonListItem pokemon) {
    _audioService.playPokemonSound(pokemon.id);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PokemonDetailView(pokemonId: pokemon.id),

        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },

        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
