import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../shared/constants.dart';

class PokemonListCard extends StatelessWidget {
  final PokemonListItem pokemon;
  final bool isDark;
  final VoidCallback onTap;

  const PokemonListCard({
    super.key,
    required this.pokemon,
    required this.isDark,
    required this.onTap,
  });

  Color _getPokemonColor() {
    if (pokemon.types.isNotEmpty) {
      final primaryType = pokemon.types.first.toLowerCase();
      return pokemonTypeColors[primaryType] ?? const Color(0xFFA8A878);
    }
    return const Color(0xFFA8A878);
  }

  @override
  Widget build(BuildContext context) {
    final artworkUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${pokemon.id}.png';

    final cardColor = _getPokemonColor();

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
          onTap: onTap,
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
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pokemon.name[0].toUpperCase() +
                            pokemon.name.substring(1),
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
}
