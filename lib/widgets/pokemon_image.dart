import 'package:flutter/material.dart';
import '../shared/constants.dart';

class PokemonImage extends StatelessWidget {
  final int pokemonId;
  final String imageUrl;
  final String primaryType;
  final bool isDark;

  const PokemonImage({
    super.key,
    required this.pokemonId,
    required this.imageUrl,
    required this.primaryType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = pokemonTypeColors[primaryType.toLowerCase()] ?? const Color(0xFFA8A878);

    return Hero(
      tag: 'pokemon-$pokemonId',
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              typeColor.withValues(alpha: 0.3),
              typeColor.withValues(alpha: 0.05),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: typeColor.withValues(alpha: 0.3),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Image.network(
          imageUrl,
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
}
