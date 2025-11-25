import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/pokemon_controller.dart';
import '../../models/pokemon.dart';
import '../../providers/theme_provider.dart';

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
  void dispose() {
    _animationController.dispose();

    final controller = context.read<PokemonController>();
    Future.microtask(() {
      controller.clearSelectedPokemon();
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

          body: _buildBody(controller, isDark),
        );
      },
    );
  }

  Widget _buildBody(PokemonController controller, bool isDark) {
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

        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 120),
              _buildImage(pokemon, isDark),
              const SizedBox(height: 24),
              _buildIdBadge(pokemon, isDark),
              const SizedBox(height: 12),
              _buildTypes(pokemon, isDark),
              const SizedBox(height: 24),
              _buildDescription(pokemon, isDark),
              const SizedBox(height: 24),
              _buildPhysicalInfo(pokemon, isDark),
              const SizedBox(height: 24),
              if (pokemon.abilities.isNotEmpty) ...[
                _buildAbilities(pokemon, isDark),
                const SizedBox(height: 24),
              ],
              _buildStats(pokemon, isDark),
              const SizedBox(height: 24),
              if (pokemon.evolutionChain.isNotEmpty) ...[
                _buildEvolutionChain(pokemon, isDark),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(Pokemon pokemon, bool isDark) {
    return Hero(
      tag: 'pokemon-${pokemon.id}',
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              _getTypeColor(pokemon.types.first).withValues(alpha: 0.3),
              _getTypeColor(pokemon.types.first).withValues(alpha: 0.05),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _getTypeColor(pokemon.types.first).withValues(alpha: 0.3),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Image.network(
          pokemon.imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.catching_pokemon,
            size: 120,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildIdBadge(Pokemon pokemon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getTypeColor(pokemon.types.first).withValues(alpha: 0.3),
            _getTypeColor(pokemon.types.first).withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getTypeColor(pokemon.types.first).withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Text(
        '#${pokemon.id.toString().padLeft(3, '0')}',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : _getTypeColor(pokemon.types.first),
        ),
      ),
    );
  }

  Widget _buildTypes(Pokemon pokemon, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pokemon.types.map((type) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getTypeColor(type),
                _getTypeColor(type).withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: _getTypeColor(type).withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            type.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescription(Pokemon pokemon, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2A2A3E),
                  const Color(0xFF1E1E2E),
                ]
              : [
                  Colors.white,
                  Colors.grey[50]!,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        pokemon.description ?? 'No description available.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          height: 1.6,
          color: isDark ? Colors.grey[300] : Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildPhysicalInfo(Pokemon pokemon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildInfoCard(
              'Height',
              '${pokemon.height / 10} m',
              Icons.height_rounded,
              isDark,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildInfoCard(
              'Weight',
              '${pokemon.weight / 10} kg',
              Icons.monitor_weight_rounded,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2A2A3E),
                  const Color(0xFF1E1E2E),
                ]
              : [
                  Colors.white,
                  Colors.grey[50]!,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: isDark ? const Color(0xFFFF6B6B) : const Color(0xFFE63946),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(Pokemon pokemon, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2A2A3E),
                  const Color(0xFF1E1E2E),
                ]
              : [
                  Colors.white,
                  Colors.grey[50]!,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Base Stats',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ...pokemon.stats.map((stat) => _buildStatBar(stat, isDark)),
        ],
      ),
    );
  }

  Widget _buildStatBar(PokemonStat stat, bool isDark) {
    const maxStat = 255.0;
    final percentage = stat.baseStat / maxStat;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat.displayName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              Text(
                stat.baseStat.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: isDark ? const Color(0xFF1E1E2E) : Colors.grey[200],
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: LinearGradient(
                    colors: [
                      _getStatColor(stat.baseStat),
                      _getStatColor(stat.baseStat).withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatColor(int value) {
    if (value < 50) return Colors.red;
    if (value < 80) return Colors.orange;
    if (value < 100) return Colors.yellow[700]!;
    if (value < 120) return Colors.lightGreen;
    return Colors.green;
  }

  Widget _buildEvolutionChain(Pokemon pokemon, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Evolution Chain',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: pokemon.evolutionChain.length,
            itemBuilder: (context, index) {
              final stage = pokemon.evolutionChain[index];
              final isLast = index == pokemon.evolutionChain.length - 1;
              final isCurrent = stage.id == pokemon.id;

              return Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (stage.id != pokemon.id) {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                PokemonDetailView(pokemonId: stage.id),
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
                    child: Container(
                      width: 110,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isCurrent
                              ? [
                                  _getTypeColor(pokemon.types.first)
                                      .withValues(alpha: 0.3),
                                  _getTypeColor(pokemon.types.first)
                                      .withValues(alpha: 0.2),
                                ]
                              : isDark
                                  ? [
                                      const Color(0xFF2A2A3E),
                                      const Color(0xFF1E1E2E),
                                    ]
                                  : [
                                      Colors.white,
                                      Colors.grey[50]!,
                                    ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: isCurrent
                            ? Border.all(
                                color: _getTypeColor(pokemon.types.first),
                                width: 2,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.network(
                            stage.imageUrl,
                            width: 70,
                            height: 70,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.catching_pokemon, size: 70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stage.displayName,
                            style: TextStyle(
                              fontWeight:
                                  isCurrent ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (stage.minLevel != null)
                            Text(
                              'Lv. ${stage.minLevel}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.grey[500] : Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAbilities(Pokemon pokemon, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF2A2A3E),
                  const Color(0xFF1E1E2E),
                ]
              : [
                  Colors.white,
                  Colors.grey[50]!,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Abilities',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: pokemon.abilities.map((ability) {
              final displayName = ability
                  .split('-')
                  .map((word) => word.isEmpty
                      ? word
                      : word[0].toUpperCase() + word.substring(1))
                  .join(' ');

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getTypeColor(pokemon.types.first).withValues(alpha: 0.2),
                      _getTypeColor(pokemon.types.first).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getTypeColor(pokemon.types.first).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: _getTypeColor(pokemon.types.first),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return const Color(0xFFFF6B6B);
      case 'water':
        return const Color(0xFF4FC3F7);
      case 'grass':
        return const Color(0xFF66BB6A);
      case 'electric':
        return const Color(0xFFFFD54F);
      case 'psychic':
        return const Color(0xFFEC407A);
      case 'ice':
        return const Color(0xFF80DEEA);
      case 'dragon':
        return const Color(0xFF5C6BC0);
      case 'dark':
        return const Color(0xFF8D6E63);
      case 'fairy':
        return const Color(0xFFF48FB1);
      case 'fighting':
        return const Color(0xFFFF7043);
      case 'flying':
        return const Color(0xFF81D4FA);
      case 'poison':
        return const Color(0xFFBA68C8);
      case 'ground':
        return const Color(0xFFA1887F);
      case 'rock':
        return const Color(0xFF90A4AE);
      case 'bug':
        return const Color(0xFF9CCC65);
      case 'ghost':
        return const Color(0xFF9575CD);
      case 'steel':
        return const Color(0xFF78909C);
      case 'normal':
      default:
        return const Color(0xFFBDBDBD);
    }
  }
}
