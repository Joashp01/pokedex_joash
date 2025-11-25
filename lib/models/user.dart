class User {

  final String uid;
  final List<int> favoritePokemonIds;


  User({
    required this.uid,
    this.favoritePokemonIds = const [],
  });

  User copyWith({
    String? uid,
    List<int>? favoritePokemonIds,
  }) {
    return User(
      uid: uid ?? this.uid,
      favoritePokemonIds: favoritePokemonIds ?? this.favoritePokemonIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'favoritePokemonIds': favoritePokemonIds,
    };
  }

  factory User.fromMap(Map<String, dynamic> map, String uid) {
    return User(
      uid: uid,
      favoritePokemonIds: List<int>.from(map['favoritePokemonIds'] ?? []),
    );
  }
}
