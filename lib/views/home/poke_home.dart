import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/pokemon_controller.dart';
import '../../models/pokemon.dart';
import '../../providers/theme_provider.dart';
import '../../services/pokemon_sound.dart';
import '../../services/auth.dart';
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
              icon: const Icon(
                Icons.logout_rounded,
                size: 22,
              ),
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
                ? [
                    const Color(0xFF1E1E2E),
                    const Color(0xFF121212),
                  ]
                : [
                    const Color(0xFFF8F9FA),
                    const Color(0xFFE8EAED),
                  ],
          ),
        ),

        child: Consumer<PokemonController>(
          builder: (context, controller, child) {
            return Column(
              children: [
                const SizedBox(height: 100),
                _buildSearchBar(controller, isDark),
                Expanded(child: _buildBody(controller, isDark)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(PokemonController controller, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF2A2A3E).withValues(alpha: 0.8),
                    const Color(0xFF1E1E2E).withValues(alpha: 0.8),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.95),
                    Colors.grey[50]!.withValues(alpha: 0.95),
                  ],
          ),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 6),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: isDark
                  ? Colors.purple.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Search Pokémon...',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[500],
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFFFF6B6B).withValues(alpha: 0.2),
                          const Color(0xFFE63946).withValues(alpha: 0.1),
                        ]
                      : [
                          const Color(0xFFE63946).withValues(alpha: 0.15),
                          const Color(0xFFE63946).withValues(alpha: 0.08),
                        ],
                ),
              ),
              child: Icon(
                Icons.search_rounded,
                color: isDark
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFFE63946),
                size: 20,
              ),
            ),
            suffixIcon: controller.isSearching
                ? Container(
                    margin: const EdgeInsets.all(8),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          size: 18,
                        ),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        controller.clearSearch();
                      },
                    ),
                  )
                : null,
            filled: false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
          onChanged: (query) {
            controller.searchPokemon(query);
          },
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

    if (controller.isSearching && displayList.isEmpty && !controller.isLoading) {
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
                color: isDark ? const Color(0xFFFF6B6B) : const Color(0xFFE63946),
              ),
            ),
          );
        }

        final pokemon = displayList[index];
        return _buildPokemonCard(pokemon, isDark);
      },
    );
  }

  Widget _buildPokemonCard(PokemonListItem pokemon, bool isDark) {
    final artworkUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${pokemon.id}.png';

    final cardColor = _getPokemonColor(pokemon.id, isDark);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      height: 120,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  cardColor.withValues(alpha: 0.15),
                  cardColor.withValues(alpha: 0.05),
                ]
              : [
                  cardColor.withValues(alpha: 0.08),
                  cardColor.withValues(alpha: 0.02),
                ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: isDark ? 0.2 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onPokemonTap(pokemon),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: 'pokemon-${pokemon.id}',
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          cardColor.withValues(alpha: isDark ? 0.3 : 0.15),
                          cardColor.withValues(alpha: 0.05),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: cardColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.network(
                      artworkUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.catching_pokemon,
                        size: 48,
                        color: cardColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '#${pokemon.id.toString().padLeft(3, '0')}',
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey[500]
                              : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cardColor.withValues(alpha: isDark ? 0.2 : 0.1),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: cardColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPokemonColor(int id, bool isDark) {
    final colors = [
      const Color(0xFF5FD89D),
      const Color(0xFFFF6B6B),
      const Color(0xFF4FC3F7),
      const Color(0xFFA4DD57),
      const Color(0xFFBA68C8),
      const Color(0xFFFFB74D),
      const Color(0xFFF06292),
      const Color(0xFFEF5350),
      const Color(0xFF9575CD),
      const Color(0xFF7E57C2),
    ];
    return colors[id % colors.length];
  }

  void _onPokemonTap(PokemonListItem pokemon) {
    _audioService.playPokemonCry(pokemon.id);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PokemonDetailView(pokemonId: pokemon.id),

        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },

        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
