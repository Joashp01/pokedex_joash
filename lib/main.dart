

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 👈 for kIsWeb
import 'package:pokedex_joash/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pokedex_joash/views/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_joash/models/user.dart';
import 'controllers/pokemon_controller.dart';
import 'providers/theme_provider.dart';
import 'services/pokemon_sound.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load environment variables
  await dotenv.load(fileName: ".env");

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: dotenv.env['API_KEY']!,
          authDomain: dotenv.env['AUTH_DOMAIN']!,
          projectId: dotenv.env['PROJECT_ID']!,
          storageBucket: dotenv.env['STORAGE_BUCKET']!,
          messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!,
          appId: dotenv.env['APP_ID']!,
        ),
      );
      debugPrint('Firebase initialized for Web');
    } else {
      await Firebase.initializeApp(); // uses google-services.json / plist
      debugPrint('Firebase initialized for Mobile/Desktop');
    }
  } catch (e, s) {
    debugPrint('Firebase initialization error: $e\n$s');
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
            debugPrint('StreamProvider error: $error');
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
