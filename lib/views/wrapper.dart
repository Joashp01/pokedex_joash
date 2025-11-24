import 'package:pokedex_joash/views/authenticate/authenticate.dart';
import 'package:pokedex_joash/views/home/poke_home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_joash/models/user.dart';
// this widget basically will listen for the current user status from StreamProvider in the main.dart
// if the user is logged in , it will show the home screen
// if not logged in show the authenticate screen 
class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {

// 
    final user = Provider.of<User?>(context);
    print (user);


    if (user == null ){
      return const Authenticate();// will go login/register 

    }else {
      return PokeHome();
    }
    
  }
}