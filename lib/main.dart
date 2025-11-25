import 'package:flutter/material.dart';
import 'package:pokedex_joash/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pokedex_joash/views/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_joash/models/user.dart';
import 'controllers/pokemon_controller.dart';
import 'providers/theme_provider.dart';
import 'services/pokemon_sound.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully ');
  } catch (e) {
    print(' Firebase initialized error : $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    // Start playing theme song when app starts
    Future.delayed(const Duration(milliseconds: 500), () {
      _audioService.playThemeSong();
    });
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: AuthService().user,

          initialData: null,

          catchError: (context, error) {
            print('StreamProvider error : $error');
            return null;
          },
        ),

        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        ChangeNotifierProvider(create: (_) => PokemonController()),

        Provider<AudioService>.value(value: _audioService),
      ],

      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Pokédex',
            debugShowCheckedModeBanner: false,

            themeMode: themeProvider.themeMode,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,

            home: Wrapper(),
          );
        },
      ),
    );
  }
}
