import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_joash/controllers/pokemon_controller.dart';
import 'package:pokedex_joash/providers/theme_provider.dart';
import 'package:pokedex_joash/shared/constants.dart';
import 'package:pokedex_joash/widgets/pokemon_image.dart';
import 'package:pokedex_joash/widgets/pokemon_id_badge.dart';
import 'package:pokedex_joash/widgets/pokemon_type_badge.dart';
import 'package:pokedex_joash/widgets/pokemon_description_card.dart';
import 'package:pokedex_joash/widgets/pokemon_info_card.dart';
import 'package:pokedex_joash/widgets/pokemon_abilities_card.dart';
import 'package:pokedex_joash/widgets/pokemon_stats_card.dart';
import 'package:pokedex_joash/widgets/pokemon_evolution_chain.dart';

class PokemonDetailView extends StatefulWidget {
  final int pokemonId;

  const PokemonDetailView({
    super.key,
    required this.pokemonId,
  });

  @override
  State<PokemonDetailView> createState() => _PokemonDetailViewState();
}

class _PokemonDetailViewState extends State<PokemonDetailView>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  PokemonController? _controller;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    Future.microtask(() {
      if (mounted) {
        context.read<PokemonController>().selectPokemon(widget.pokemonId);
        _animationController.forward();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= context.read<PokemonController>();
  }

  @override
  void dispose() {
    _animationController.dispose();

    if (_controller != null) {
      Future.microtask(() {
        _controller!.clearSelectedPokemon();
      });
    }

    super.dispose();
  }

  Color _getTypeColor(String type) {
    return pokemonTypeColors[type.toLowerCase()] ?? const Color(0xFFA8A878);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 1200 ? 1200.0 : screenWidth;

    return Consumer2<PokemonController, ThemeProvider>(
      builder: (context, controller, themeProvider, child) {
        final pokemon = controller.selectedPokemon;
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          extendBodyBehindAppBar: true,

          appBar: AppBar(
            title: Text(pokemon != null
                ? pokemon.name[0].toUpperCase() + pokemon.name.substring(1)
                : 'Loading...'),

            backgroundColor: pokemon != null
                ? _getTypeColor(pokemon.types.first).withValues(alpha: 0.9)
                : (isDark
                    ? const Color(0xFF1E1E2E).withValues(alpha: 0.9)
                    : const Color(0xFFE63946).withValues(alpha: 0.9)),

            elevation: 0,
            foregroundColor: Colors.white,

            actions: pokemon != null
                ? [
                    IconButton(
                      icon: Icon(
                        controller.isFavorite(pokemon.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      onPressed: () async {
                        await controller.toggleFavorite(pokemon.id);
                      },
                      tooltip: controller.isFavorite(pokemon.id)
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                    ),
                  ]
                : null,
          ),

          body: _buildBody(controller, isDark, maxWidth),
        );
      },
    );
  }

  Widget _buildBody(PokemonController controller, bool isDark, double maxWidth) {
    if (controller.isLoading) {
      return Container(
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
        child: Center(
          child: CircularProgressIndicator(
            color: isDark ? const Color(0xFFFF6B6B) : const Color(0xFFE63946),
          ),
        ),
      );
    }

    if (controller.error != null) {
      return Container(
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
        child: Center(
          child: Text(
            'Error: ${controller.error}',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
        ),
      );
    }

    final pokemon = controller.selectedPokemon;
    if (pokemon == null) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    _getTypeColor(pokemon.types.first).withValues(alpha: 0.3),
                    const Color(0xFF121212),
                  ]
                : [
                    _getTypeColor(pokemon.types.first).withValues(alpha: 0.1),
                    const Color(0xFFE8EAED),
                  ],
          ),
        ),

        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 120),
              PokemonImage(
                pokemonId: pokemon.id,
                imageUrl: pokemon.imageUrl,
                primaryType: pokemon.types.first,
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              PokemonIdBadge(
                id: pokemon.id,
                primaryType: pokemon.types.first,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: pokemon.types.map((type) {
                  return PokemonTypeBadge(type: type);
                }).toList(),
              ),
              const SizedBox(height: 24),
              PokemonDescriptionCard(
                description: pokemon.description,
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: PokemonInfoCard(
                        label: 'Height',
                        value: '${pokemon.height / 10} m',
                        icon: Icons.height_rounded,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PokemonInfoCard(
                        label: 'Weight',
                        value: '${pokemon.weight / 10} kg',
                        icon: Icons.monitor_weight_rounded,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (pokemon.abilities.isNotEmpty) ...[
                PokemonAbilitiesCard(
                  abilities: pokemon.abilities,
                  primaryType: pokemon.types.first,
                  isDark: isDark,
                ),
                const SizedBox(height: 24),
              ],
              PokemonStatsCard(
                stats: pokemon.stats,
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              if (pokemon.evolutionChain.isNotEmpty) ...[
                PokemonEvolutionChain(
                  evolutionChain: pokemon.evolutionChain,
                  currentPokemonId: pokemon.id,
                  primaryType: pokemon.types.first,
                  isDark: isDark,
                  onEvolutionTap: (pokemonId) {
                    if (pokemonId != pokemon.id) {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              PokemonDetailView(pokemonId: pokemonId),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }
}
