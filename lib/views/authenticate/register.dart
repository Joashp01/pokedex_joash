import 'package:flutter/material.dart';
import 'package:pokedex_joash/services/auth.dart';
import 'package:pokedex_joash/shared/constants.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  const Register({super.key, required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();// this will talk to firebase
  final _formkey = GlobalKey<FormState>();// validates our forms 

  // form field values 

  String email = '';
  String password = '';
  String error = '';





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0.0,
        title: Text('Welcome Pokéfan , Sign up'),
        actions: <Widget>[
          TextButton.icon(
            icon:Icon(Icons.person),
            label:Text('Sign in'),
            onPressed: (){
              widget.toggleView();
            }
            )
        ],


      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Form(
          key: _formkey,
          child:Column(
            children: <Widget>[
              SizedBox(height: 20,),
              TextFormField(
                decoration:textInputDecoration.copyWith(hintText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter an email' : null,
                onChanged: (val){
                  setState(() =>email = val);
                }
              ),

              SizedBox(height: 20.0),

              TextFormField(
                decoration: textInputDecoration.copyWith(hintText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length <6 ? ' Enter a password 6+ characters or more ': null,
                onChanged: (val){
                  setState(() => password = val);
                },
              ),
              SizedBox(height: 20.0,),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor:Colors.white,
                ),
                
                onPressed:() async{
                   dynamic result = await _auth.registerWithEmailAndPassword(email, password);

                   if (result == null){
                    setState(() {
                      error = 'Please supply valid email';
                    });
                   }

                },
                child: Text('Register'),
                
                ),

                SizedBox(height: 12.0,),

                Text(
                  error,
                  style: TextStyle(color:Colors.red, fontSize: 14.0),
                )

          
            ],
          ),
        ),
      ),
    );
  }
}