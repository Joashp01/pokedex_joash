// =============================================================================
// POKEMON_DETAIL_VIEW.DART - THE DETAILED INFORMATION SCREEN FOR ONE POKEMON
// =============================================================================
// When you tap a Pokemon in the list, this screen opens and shows you
// EVERYTHING about that Pokemon:
// - Large image
// - Type badges (Fire, Water, etc.)
// - Description text (the Pokedex entry)
// - Height and weight
// - Base stats (HP, Attack, Defense, etc.) with progress bars
// - Evolution chain (what it evolves from/into)
// - Moves it can learn
//
// This is the "detail view" - think of it like opening a Pokemon card
// to see all the fine print on the back.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/pokemon_controller.dart';
import '../../models/pokemon.dart';
import '../../providers/theme_provider.dart';

// -----------------------------------------------------------------------------
// POKEMONDETAILVIEW CLASS - The detail screen widget
// -----------------------------------------------------------------------------
// This is a StatefulWidget because it has animations and needs to load data.
class PokemonDetailView extends StatefulWidget {
  // The ID of the Pokemon to display (e.g., 25 for Pikachu)
  // This is passed in from the list screen when you tap a Pokemon
  final int pokemonId;

  const PokemonDetailView({
    super.key,
    required this.pokemonId, // Required - we MUST know which Pokemon to show
  });

  @override
  State<PokemonDetailView> createState() => _PokemonDetailViewState();
}

// -----------------------------------------------------------------------------
// _POKEMONDETAILVIEWSTATE - The state for the detail screen
// -----------------------------------------------------------------------------
// "with SingleTickerProviderStateMixin" enables animations.
// Think of it like adding animation capabilities to this widget.
class _PokemonDetailViewState extends State<PokemonDetailView>
    with SingleTickerProviderStateMixin {
  // ===========================================================================
  // ANIMATION CONTROLLERS
  // ===========================================================================
  // These control the fade-in animation when the screen appears.
  // The content fades from invisible (0.0) to fully visible (1.0).

  late AnimationController _animationController; // Controls the animation timing
  late Animation<double> _fadeAnimation; // The actual fade effect (0.0 to 1.0)

  // ===========================================================================
  // INITSTATE - Setup when screen first appears
  // ===========================================================================
  @override
  void initState() {
    super.initState();

    // STEP 1: Create the animation controller
    // This controls HOW LONG the animation takes (600 milliseconds)
    // "vsync: this" is required for smooth animations - it syncs with screen refresh
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // STEP 2: Create the fade animation
    // Goes from 0.0 (invisible) to 1.0 (fully visible)
    // Uses "easeInOut" curve for smooth acceleration and deceleration
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // STEP 3: Fetch the Pokemon data and start animation
    // "Future.microtask" delays slightly to ensure widget is ready
    Future.microtask(() {
      if (mounted) {
        // "mounted" checks if widget is still on screen
        // Tell controller to fetch this Pokemon's full details
        context.read<PokemonController>().selectPokemon(widget.pokemonId);
        // Start the fade-in animation
        _animationController.forward();
      }
    });
  }

  // ===========================================================================
  // DISPOSE - Cleanup when leaving the screen
  // ===========================================================================
  // Free up resources when the user goes back to the list
  @override
  void dispose() {
    _animationController.dispose(); // Free animation controller memory

    // Clear the selected Pokemon from the controller
    // This keeps memory usage low - we don't keep full Pokemon details in memory
    // when we're not viewing them
    final controller = context.read<PokemonController>();
    Future.microtask(() {
      controller.clearSelectedPokemon();
    });

    super.dispose();
  }

  // ===========================================================================
  // BUILD - Constructs the detail screen UI
  // ===========================================================================
  // This method builds the entire Pokemon detail screen.
  // It listens to BOTH PokemonController (for data) and ThemeProvider (for theme).
  @override
  Widget build(BuildContext context) {
    // Consumer2 listens to TWO providers at once
    // Rebuilds when either PokemonController or ThemeProvider changes
    return Consumer2<PokemonController, ThemeProvider>(
      builder: (context, controller, themeProvider, child) {
        final pokemon = controller.selectedPokemon; // Get the Pokemon data
        final isDark = themeProvider.isDarkMode; // Check if dark mode

        return Scaffold(
          // Allow content to go behind the app bar (for gradient effect)
          extendBodyBehindAppBar: true,

          // ===========================================================================
          // APP BAR - Top bar with Pokemon name and back button
          // ===========================================================================
          // The app bar color matches the Pokemon's type (Fire = red, Water = blue, etc.)
          appBar: AppBar(
            // Show Pokemon name (capitalized) or "Loading..." if still fetching
            title: Text(pokemon != null
                ? pokemon.name[0].toUpperCase() + pokemon.name.substring(1)
                : 'Loading...'),

            // Background color based on Pokemon's primary type
            // If no Pokemon yet, use default red (light) or dark purple (dark)
            backgroundColor: pokemon != null
                ? _getTypeColor(pokemon.types.first).withValues(alpha: 0.9)
                : (isDark
                    ? const Color(0xFF1E1E2E).withValues(alpha: 0.9)
                    : const Color(0xFFE63946).withValues(alpha: 0.9)),

            elevation: 0, // No shadow
            foregroundColor: Colors.white, // White text and back button
          ),

          // Build the main content (loading spinner, error, or Pokemon details)
          body: _buildBody(controller, isDark),
        );
      },
    );
  }

  // ===========================================================================
  // _BUILDBODY - Decides what to show based on loading state
  // ===========================================================================
  // Similar to the list view, this checks the state and shows:
  // 1. Loading spinner - while fetching Pokemon data
  // 2. Error message - if something went wrong
  // 3. Pokemon details - the full scrollable view with all info
  Widget _buildBody(PokemonController controller, bool isDark) {
    // ---------------------------------------------------------------------------
    // STATE 1: Loading
    // ---------------------------------------------------------------------------
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

    // ---------------------------------------------------------------------------
    // STATE 2: Error
    // ---------------------------------------------------------------------------
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

    // ---------------------------------------------------------------------------
    // STATE 3: Success - Show Pokemon Details
    // ---------------------------------------------------------------------------
    final pokemon = controller.selectedPokemon;
    if (pokemon == null) {
      return const SizedBox.shrink(); // Empty widget if no Pokemon
    }

    // Wrap everything in FadeTransition for smooth fade-in effect
    return FadeTransition(
      opacity: _fadeAnimation, // Use our fade animation
      child: Container(
        // Background gradient that includes the Pokemon's type color
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

        // Scrollable column with all Pokemon information sections
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // iOS-style bouncy scroll
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 120), // Space for app bar
              _buildImage(pokemon, isDark), // Large Pokemon image
              const SizedBox(height: 24),
              _buildIdBadge(pokemon, isDark), // Pokemon number badge
              const SizedBox(height: 12),
              _buildTypes(pokemon, isDark), // Type badges (Fire, Water, etc.)
              const SizedBox(height: 24),
              _buildDescription(pokemon, isDark), // Pokedex description
              const SizedBox(height: 24),
              _buildPhysicalInfo(pokemon, isDark), // Height and weight cards
              const SizedBox(height: 24),
              // Show abilities above stats
              if (pokemon.abilities.isNotEmpty) ...[
                _buildAbilities(pokemon, isDark),
                const SizedBox(height: 24),
              ],
              _buildStats(pokemon, isDark), // Stats with progress bars
              const SizedBox(height: 24),
              // Only show evolution chain if it exists
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

  // ===========================================================================
  // _BUILDIMAGE - Creates the large Pokemon image at the top
  // ===========================================================================
  // The image is wrapped in a Hero widget so it animates smoothly from the
  // list screen. It has a glowing circular background matching the Pokemon's type.
  Widget _buildImage(Pokemon pokemon, bool isDark) {
    return Hero(
      tag: 'pokemon-${pokemon.id}', // Matches the tag from the list screen
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Circular background
          // Radial gradient - color fades from center outward
          gradient: RadialGradient(
            colors: [
              _getTypeColor(pokemon.types.first).withValues(alpha: 0.3), // Center
              _getTypeColor(pokemon.types.first).withValues(alpha: 0.05), // Edge
            ],
          ),
          // Glowing shadow effect matching the Pokemon's type color
          boxShadow: [
            BoxShadow(
              color: _getTypeColor(pokemon.types.first).withValues(alpha: 0.3),
              blurRadius: 40, // How spread out the glow is
              spreadRadius: 10, // How far the glow extends
            ),
          ],
        ),
        // Load the image from the internet
        child: Image.network(
          pokemon.imageUrl,
          fit: BoxFit.contain,
          // Fallback icon if image fails to load
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.catching_pokemon,
            size: 120,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // _BUILDIDBADGE - Shows the Pokemon number (e.g., #025)
  // ===========================================================================
  // The badge is styled with the Pokemon's type color for visual consistency.
  Widget _buildIdBadge(Pokemon pokemon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        // Gradient background matching type color
        gradient: LinearGradient(
          colors: [
            _getTypeColor(pokemon.types.first).withValues(alpha: 0.3),
            _getTypeColor(pokemon.types.first).withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        // Border matching type color
        border: Border.all(
          color: _getTypeColor(pokemon.types.first).withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Text(
        '#${pokemon.id.toString().padLeft(3, '0')}', // Format with leading zeros
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : _getTypeColor(pokemon.types.first),
        ),
      ),
    );
  }

  // ===========================================================================
  // _BUILDTYPES - Shows type badges (Fire, Water, Electric, etc.)
  // ===========================================================================
  // Pokemon can have 1 or 2 types. Each type gets a colored badge.
  // Colors are chosen to match the traditional Pokemon type colors.
  Widget _buildTypes(Pokemon pokemon, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      // Map each type to a badge widget
      children: pokemon.types.map((type) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            // Gradient for each type's color
            gradient: LinearGradient(
              colors: [
                _getTypeColor(type), // Full color
                _getTypeColor(type).withValues(alpha: 0.8), // Slightly transparent
              ],
            ),
            borderRadius: BorderRadius.circular(25), // Pill shape
            // Drop shadow for depth
            boxShadow: [
              BoxShadow(
                color: _getTypeColor(type).withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            type.toUpperCase(), // "fire" -> "FIRE"
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

  // ===========================================================================
  // _BUILDDESCRIPTION - Shows the Pokedex entry text
  // ===========================================================================
  // This displays the classic Pokedex "flavor text" - the description of the
  // Pokemon that you'd see in the games. For example:
  // "It stores electrical energy under very high pressure. It often explodes
  // with little or no provocation."
  Widget _buildDescription(Pokemon pokemon, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      // Card styling with gradient
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
        // Show description if available, otherwise show fallback message
        pokemon.description ?? 'No description available.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          height: 1.6, // Line height for readability
          color: isDark ? Colors.grey[300] : Colors.grey[800],
        ),
      ),
    );
  }

  // ===========================================================================
  // _BUILDPHYSICALINFO - Shows height and weight side by side
  // ===========================================================================
  // The API returns height in decimeters and weight in hectograms, so we
  // divide by 10 to get standard units (meters and kilograms).
  Widget _buildPhysicalInfo(Pokemon pokemon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Height card (left side)
          Expanded(
            child: _buildInfoCard(
              'Height',
              '${pokemon.height / 10} m', // Convert decimeters to meters
              Icons.height_rounded,
              isDark,
            ),
          ),
          const SizedBox(width: 16), // Space between cards
          // Weight card (right side)
          Expanded(
            child: _buildInfoCard(
              'Weight',
              '${pokemon.weight / 10} kg', // Convert hectograms to kilograms
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

  // ===========================================================================
  // _BUILDSTATS - Shows all 6 base stats with progress bars
  // ===========================================================================
  // Pokemon have 6 stats: HP, Attack, Defense, Special Attack, Special Defense,
  // and Speed. Each stat is shown with:
  // - The stat name (e.g., "Attack")
  // - The stat value (e.g., "100")
  // - A colored progress bar showing how good the stat is
  //
  // The bar color changes based on value (red = weak, green = strong).
  Widget _buildStats(Pokemon pokemon, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      // Card styling
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
          // Section title
          Text(
            'Base Stats',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          // Build a stat bar for each of the 6 stats
          // The "..." spreads the list of widgets into the children array
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

  // ===========================================================================
  // _GETSTATCOLOR - Returns a color based on stat value
  // ===========================================================================
  // This creates a visual indicator of how good a stat is:
  // - Red: Poor (< 50)
  // - Orange: Below average (50-79)
  // - Yellow: Average (80-99)
  // - Light Green: Above average (100-119)
  // - Green: Excellent (120+)
  //
  // This helps users quickly understand if a Pokemon is strong in a stat.
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

  // ===========================================================================
  // _BUILDABILITIES - Shows Pokemon abilities
  // ===========================================================================
  // Displays all the abilities this Pokemon has (e.g., Static, Lightning Rod)
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
              // Format ability name: "lightning-rod" -> "Lightning Rod"
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

  // ===========================================================================
  // _GETTYPECOLOR - Maps Pokemon types to their traditional colors
  // ===========================================================================
  // This is a crucial function that provides visual consistency throughout the app.
  // Each Pokemon type has a specific color that matches the traditional Pokemon
  // games and card game.
  //
  // WHY THIS MATTERS:
  // - The app bar color changes based on the Pokemon's type
  // - Type badges use these colors
  // - Background gradients incorporate these colors
  // - Evolution chain highlights use these colors
  //
  // This creates a cohesive visual experience where Fire Pokemon feel "fiery"
  // with warm red colors, Water Pokemon feel "cool" with blue, etc.
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return const Color(0xFFFF6B6B); // Warm red/orange
      case 'water':
        return const Color(0xFF4FC3F7); // Cool blue
      case 'grass':
        return const Color(0xFF66BB6A); // Fresh green
      case 'electric':
        return const Color(0xFFFFD54F); // Bright yellow
      case 'psychic':
        return const Color(0xFFEC407A); // Pink/magenta
      case 'ice':
        return const Color(0xFF80DEEA); // Light cyan
      case 'dragon':
        return const Color(0xFF5C6BC0); // Deep purple/blue
      case 'dark':
        return const Color(0xFF8D6E63); // Dark brown
      case 'fairy':
        return const Color(0xFFF48FB1); // Soft pink
      case 'fighting':
        return const Color(0xFFFF7043); // Burnt orange
      case 'flying':
        return const Color(0xFF81D4FA); // Sky blue
      case 'poison':
        return const Color(0xFFBA68C8); // Purple
      case 'ground':
        return const Color(0xFFA1887F); // Earthy brown
      case 'rock':
        return const Color(0xFF90A4AE); // Grey
      case 'bug':
        return const Color(0xFF9CCC65); // Yellow-green
      case 'ghost':
        return const Color(0xFF9575CD); // Deep purple
      case 'steel':
        return const Color(0xFF78909C); // Metallic grey
      case 'normal':
      default:
        return const Color(0xFFBDBDBD); // Neutral grey (default fallback)
    }
  }
}
