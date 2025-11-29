import 'package:flutter/material.dart';

class PokemonSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final bool isSearching;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const PokemonSearchBar({
    super.key,
    required this.controller,
    required this.isDark,
    required this.isSearching,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
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
          controller: controller,
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
            suffixIcon: isSearching
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
                      onPressed: onClear,
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
          onChanged: onChanged,
        ),
      ),
    );
  }
}
