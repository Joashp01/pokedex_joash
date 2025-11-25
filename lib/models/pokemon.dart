
class Pokemon {
  final int id;              // Pokemon's number (like #25 for Pikachu)
  final String name;         // Pokemon's name (like "pikachu")
  final String imageUrl;     // Web address where we can load the Pokemon's picture
  final List<String> types;  // Pokemon's types (like ["electric"] or ["fire", "flying"])
  final List<PokemonStat> stats; // Pokemon's battle stats (HP, Attack, Defense, etc.)
  final int height;          // How tall the Pokemon is (in decimeters)
  final int weight;          // How heavy the Pokemon is (in hectograms)
  final String? description; // Pokemon's Pokedex description (the ? means this can be empty)
  final List<String> abilities; // Special abilities this Pokemon has
  final List<EvolutionStage> evolutionChain; // Evolution chain (like Charmander -> Charmeleon -> Charizard)

  // Constructor - this is the function we use to create a new Pokemon object
  // "required" means you MUST provide this value when creating a Pokemon
  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.stats,
    required this.height,
    required this.weight,
    this.description,              // Not required - can be null
    this.abilities = const [],     // If not provided, defaults to empty list
    this.evolutionChain = const [], // If not provided, defaults to empty list
  });

  // Factory constructor - this converts JSON data from the API into a Pokemon object
  // "factory" means this returns a Pokemon object rather than creating it normally
  // JSON is data format that comes from the internet (looks like: {"id": 25, "name": "pikachu"})
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // Extract the types from the JSON
    // The API gives us types in a nested structure, so we need to dig into it
    List<String> types = (json['types'] as List)
        .map((typeData) => typeData['type']['name'] as String)
        .toList();

    // Extract the stats from the JSON
    // We convert each stat data into a PokemonStat object
    List<PokemonStat> stats = (json['stats'] as List)
        .map((statData) => PokemonStat.fromJson(statData))
        .toList();

    // Get the best quality image URL from the API response
    // The ?? operator means "if the left value is null, use the right value instead"
    String imageUrl = json['sprites']['other']['official-artwork']
            ['front_default'] ??
        json['sprites']['front_default'] ??
        '';

    // Create and return a new Pokemon object with all the data we extracted
    return Pokemon(
      id: json['id'],
      name: json['name'],
      imageUrl: imageUrl,
      types: types,
      stats: stats,
      height: json['height'],
      weight: json['weight'],
    );
  }

  // copyWith method - creates a copy of this Pokemon with some fields updated
  // This is useful when we want to add description/abilities later without changing the original
  // Since Pokemon objects are "immutable" (can't be changed), we create a new one instead
  Pokemon copyWith({
    String? description,
    List<String>? abilities,
    List<EvolutionStage>? evolutionChain,
  }) {
    // Create a new Pokemon with all the same data as this one
    return Pokemon(
      id: id,                    // Keep the same ID
      name: name,                // Keep the same name
      imageUrl: imageUrl,        // Keep the same image
      types: types,              // Keep the same types
      stats: stats,              // Keep the same stats
      height: height,            // Keep the same height
      weight: weight,            // Keep the same weight
      // Use new value if provided, otherwise keep the old value
      description: description ?? this.description,
      abilities: abilities ?? this.abilities,
      evolutionChain: evolutionChain ?? this.evolutionChain,
    );
  }
}

// PokemonStat class - holds information about one stat (like HP or Attack)
// Pokemon have 6 stats total: HP, Attack, Defense, Special Attack, Special Defense, and Speed
class PokemonStat {
  final String name;     // The stat name from the API (like "special-attack")
  final int baseStat;    // The stat value (like 100)

  // Constructor - creates a new stat object
  PokemonStat({
    required this.name,
    required this.baseStat,
  });

  // Factory constructor - converts JSON data into a PokemonStat object
  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      name: json['stat']['name'],    // Get the stat name from nested JSON
      baseStat: json['base_stat'],   // Get the stat value
    );
  }

  // displayName getter - converts API names into user-friendly names
  // A "getter" is a computed property - it calculates a value when you access it
  // Example: "special-attack" becomes "Sp. Atk"
  String get displayName {
    switch (name) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Attack';
      case 'defense':
        return 'Defense';
      case 'special-attack':
        return 'Sp. Atk';
      case 'special-defense':
        return 'Sp. Def';
      case 'speed':
        return 'Speed';
      default:
        return name;  // If we don't recognize it, just return the original name
    }
  }
}

// PokemonListItem class - a lightweight version of Pokemon for the list screen
// We don't need ALL the Pokemon data when just showing a list, so this saves memory
// This only has name and URL - we can fetch full details later when needed
class PokemonListItem {
  final String name;  // Pokemon's name (like "pikachu")
  final String url;   // URL where we can get full details about this Pokemon

  // Constructor
  PokemonListItem({
    required this.name,
    required this.url,
  });

  // Factory constructor - converts JSON to PokemonListItem
  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    return PokemonListItem(
      name: json['name'],
      url: json['url'],
    );
  }

  // id getter - extracts the Pokemon ID from the URL
  // Example: "https://pokeapi.co/api/v2/pokemon/25/" -> 25
  // This is a "computed property" - it calculates the ID on the fly
  int get id {
    final uri = Uri.parse(url);  // Parse the URL string into a Uri object
    // Get all path segments (parts between slashes) and remove empty ones
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    // The last segment is the ID number - convert it from string to int
    return int.parse(segments.last);
  }
}

// EvolutionStage class - represents one stage in a Pokemon's evolution chain
// Example: For Charmander's evolution line, there are 3 stages:
// Stage 1: Charmander (evolves at level 16)
// Stage 2: Charmeleon (evolves at level 36)
// Stage 3: Charizard (final form)
class EvolutionStage {
  final int id;           // Pokemon ID for this evolution stage
  final String name;      // Pokemon name for this evolution stage
  final String imageUrl;  // Image URL for this Pokemon
  final int? minLevel;    // Minimum level needed to evolve (? means optional - some don't have levels)
  final String? trigger;  // How it evolves (like "level-up", "use-item", etc.)

  // Constructor
  EvolutionStage({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.minLevel,   // Optional - not all evolutions have a level requirement
    this.trigger,    // Optional - not all evolutions have a trigger
  });

  // displayName getter - capitalizes the first letter of the name
  // Example: "charmander" -> "Charmander"
  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }
}
