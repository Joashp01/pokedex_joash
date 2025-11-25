import 'package:pokedex_joash/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService{

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> _userFromFirebaseUser(fb.User? user) async {
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        return User.fromMap(doc.data()!, user.uid);
      } else {
        final newUser = User(uid: user.uid);
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        return newUser;
      }
    } catch (e) {
      print('Error loading user data: $e');
      return User(uid: user.uid);
    }
  }

  Stream<User?> get user {
    return _auth.authStateChanges()
    .asyncMap((fb.User? user) async => await _userFromFirebaseUser(user));
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try{
      fb.UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);

      fb.User? user = result.user;

      return _userFromFirebaseUser(user);
    }catch(e){
      print('Error signing in : $e');
      return null;
    }
  }

  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try{
      print(' Pokedex registration strating ');

      fb.UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      fb.User? user = result.user;

      if (user == null){
        print('User is null after registration ');
        return null;
      }

      print ('Pokedex user created with uid: ${user.uid}');

      return _userFromFirebaseUser(user);

    }catch(e){
      print('Error registering : $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try{
      return await _auth.signOut();
    }catch(e){
      print('Error signing out : $e');
    }
  }

  Future<bool> addFavorite(int pokemonId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('users').doc(user.uid).update({
        'favoritePokemonIds': FieldValue.arrayUnion([pokemonId]),
      });

      return true;
    } catch (e) {
      print('Error adding favorite: $e');
      return false;
    }
  }

  Future<bool> removeFavorite(int pokemonId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('users').doc(user.uid).update({
        'favoritePokemonIds': FieldValue.arrayRemove([pokemonId]),
      });

      return true;
    } catch (e) {
      print('Error removing favorite: $e');
      return false;
    }
  }

  Future<bool> toggleFavorite(int pokemonId, bool isFavorite) async {
    if (isFavorite) {
      return await removeFavorite(pokemonId);
    } else {
      return await addFavorite(pokemonId);
    }
  }

  Future<User?> getCurrentUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return User.fromMap(doc.data()!, user.uid);
      }

      return User(uid: user.uid);
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

}
