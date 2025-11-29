import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../shared/constants.dart';

class PokemonEvolutionChain extends StatelessWidget {
  final List<EvolutionStage> evolutionChain;
  final int currentPokemonId;
  final String primaryType;
  final bool isDark;
  final Function(int pokemonId) onEvolutionTap;

  const PokemonEvolutionChain({
    super.key,
    required this.evolutionChain,
    required this.currentPokemonId,
    required this.primaryType,
    required this.isDark,
    required this.onEvolutionTap,
  });

  @override
  Widget build(BuildContext context) {
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
            itemCount: evolutionChain.length,
            itemBuilder: (context, index) {
              final stage = evolutionChain[index];
              final isLast = index == evolutionChain.length - 1;
              final isCurrent = stage.id == currentPokemonId;

              return Row(
                children: [
                  _EvolutionStageCard(
                    stage: stage,
                    isCurrent: isCurrent,
                    primaryType: primaryType,
                    isDark: isDark,
                    onTap: () => onEvolutionTap(stage.id),
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
}

class _EvolutionStageCard extends StatelessWidget {
  final EvolutionStage stage;
  final bool isCurrent;
  final String primaryType;
  final bool isDark;
  final VoidCallback onTap;

  const _EvolutionStageCard({
    required this.stage,
    required this.isCurrent,
    required this.primaryType,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = pokemonTypeColors[primaryType.toLowerCase()] ?? const Color(0xFFA8A878);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isCurrent
                ? [
                    typeColor.withValues(alpha: 0.3),
                    typeColor.withValues(alpha: 0.2),
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
                  color: typeColor,
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
            Flexible(
              child: Image.network(
                stage.imageUrl,
                width: 70,
                height: 70,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.catching_pokemon, size: 70),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stage.displayName,
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
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
    );
  }
}
