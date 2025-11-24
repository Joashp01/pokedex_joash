import 'package:flutter/material.dart';
import 'package:pokedex_joash/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pokedex_joash/views/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:pokedex_joash/models/user.dart';


void main() async{
// this basically tells flutter to get ready before we start firebase
  WidgetsFlutterBinding.ensureInitialized();

  try{
    // connect to firebase
    await Firebase.initializeApp();
    print('Firebase initialized successfully ');

  } catch (e){
    print(' Firebase initialized error : $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // StreamProvider will listen to Authservice user stream 
    // when ever a user logs in or out the stream activates and listeners rebuild 
    return StreamProvider<User?>.value(
      value: AuthService().user,
      initialData: null,// we start with no user until firebase tells us login status 
      catchError: (context,error){
        print('StreamProvider error : $error');
        return null;
      },
       
       child: MaterialApp(
        home: Wrapper(),
        debugShowCheckedModeBanner: false,
       ),

      
    );
  }
}

