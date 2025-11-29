import 'package:flutter/material.dart';
import '../shared/constants.dart';

class PokemonIdBadge extends StatelessWidget {
  final int id;
  final String primaryType;
  final bool isDark;

  const PokemonIdBadge({
    super.key,
    required this.id,
    required this.primaryType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = pokemonTypeColors[primaryType.toLowerCase()] ?? const Color(0xFFA8A878);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            typeColor.withValues(alpha: 0.3),
            typeColor.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Text(
        '#${id.toString().padLeft(3, '0')}',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : typeColor,
        ),
      ),
    );
  }
}
