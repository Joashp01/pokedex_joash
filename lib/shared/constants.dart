import 'package:flutter/material.dart';

const Color pokeRed = Color(0xFFE3350D);
const Color pokeRedDark = Color(0xFFCC0000);
const Color pokeBlue = Color(0xFF3B5CA8);
const Color pokeYellow = Color(0xFFFFCB05);
const Color pokeDarkGrey = Color(0xFF2C2C2C);
const Color pokeLightGrey = Color(0xFFF5F5F5);

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  hintStyle: TextStyle(
    color: Colors.grey,
    fontSize: 15,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(30)),
    borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(30)),
    borderSide: BorderSide(color: pokeRed, width: 2.0),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(30)),
    borderSide: BorderSide(color: Color(0xFFE57373), width: 1.5),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(30)),
    borderSide: BorderSide(color: Colors.red, width: 2.0),
  ),
);
