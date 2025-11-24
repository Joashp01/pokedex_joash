import 'package:pokedex_joash/services/auth.dart';
import 'package:pokedex_joash/shared/constants.dart';
import 'package:flutter/material.dart';


class SignIn extends StatefulWidget {

  final Function toggleView;
  const SignIn({super.key, required this.toggleView});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  
  final AuthService _auth =AuthService();
  final _formkey = GlobalKey<FormState>();
  
  String email = '';
  String password= '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0.0,
        title: Text('Welcome back Pokéfan'),
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person),
            label: Text('Register'),
            onPressed:(){
              widget.toggleView();
            },
            
            )
        ],

      ),
      body: Container(
        padding:EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Form(
          key:_formkey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20,),

              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Email'),
                validator: (value) => value!.isEmpty ? ' Enter an email ': null,
                onChanged: (val){
                  setState(() => email = val );
                },

              ),
              SizedBox(height: 20.0),

              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? ' Enter a password 6+ character or more ': null,
                onChanged: (val){
                  setState(() => password = val );
                },

              ),
              SizedBox(height: 20.0,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,

                ),
              onPressed:() async {

                if (_formkey.currentState!.validate()){
                  dynamic result = await _auth.signInWithEmailAndPassword(email, password);

                  if (result == null){

                    setState(() {
                      error = ' Could not sign in with those credentials';
                    });

                  }


                }


              },
              child: Text('Sign in'),
                
                ),

                SizedBox(height: 20.0),

                Text(
                  error,
                  style: TextStyle(color:Colors.red, fontSize : 14.0),
                )

            ],
          ),
        ),
      ),
    );
  }
}