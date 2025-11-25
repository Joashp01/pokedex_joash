
class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final List<PokemonStat> stats;
  final int height;
  final int weight;
  final String? description;
  final List<String> abilities;
  final List<EvolutionStage> evolutionChain;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.stats,
    required this.height,
    required this.weight,
    this.description,
    this.abilities = const [],
    this.evolutionChain = const [],
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    List<String> types = (json['types'] as List)
        .map((typeData) => typeData['type']['name'] as String)
        .toList();

    List<PokemonStat> stats = (json['stats'] as List)
        .map((statData) => PokemonStat.fromJson(statData))
        .toList();

    String imageUrl = json['sprites']['other']['official-artwork']
            ['front_default'] ??
        json['sprites']['front_default'] ??
        '';

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

  Pokemon copyWith({
    String? description,
    List<String>? abilities,
    List<EvolutionStage>? evolutionChain,
  }) {
    return Pokemon(
      id: id,
      name: name,
      imageUrl: imageUrl,
      types: types,
      stats: stats,
      height: height,
      weight: weight,
      description: description ?? this.description,
      abilities: abilities ?? this.abilities,
      evolutionChain: evolutionChain ?? this.evolutionChain,
    );
  }
}

class PokemonStat {
  final String name;
  final int baseStat;

  PokemonStat({
    required this.name,
    required this.baseStat,
  });

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      name: json['stat']['name'],
      baseStat: json['base_stat'],
    );
  }

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
        return name;
    }
  }
}

class PokemonListItem {
  final String name;
  final String url;
  final List<String> types;

  PokemonListItem({
    required this.name,
    required this.url,
    this.types = const [],
  });

  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    return PokemonListItem(
      name: json['name'],
      url: json['url'],
      types: json['types'] != null
          ? (json['types'] as List).map((t) => t.toString()).toList()
          : [],
    );
  }

  int get id {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    return int.parse(segments.last);
  }
}

class EvolutionStage {
  final int id;
  final String name;
  final String imageUrl;
  final int? minLevel;
  final String? trigger;

  EvolutionStage({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.minLevel,
    this.trigger,
  });

  String get displayName {
    return name[0].toUpperCase() + name.substring(1);
  }
}
