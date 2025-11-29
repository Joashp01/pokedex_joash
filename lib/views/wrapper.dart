import 'package:pokedex_joash/views/authenticate/authenticate.dart';
import 'package:pokedex_joash/views/home/poke_home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_joash/models/user.dart';
import 'package:pokedex_joash/controllers/pokemon_controller.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    final pokemonController = Provider.of<PokemonController>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      pokemonController.setUser(user);
      pokemonController.initializeConnectivity();
      if (user != null) {
        pokemonController.loadUserData();
      }
    });

    debugPrint(user?.toString());

    if (user == null) {
      return const Authenticate();
    } else {
      return const PokemonListView();
    }
  }
}
