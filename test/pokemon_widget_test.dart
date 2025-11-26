import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart'; 


void main (){
  group('Pokedex widget tests ',(){
    testWidgets('Pokemon card will display name and ID correctly ',(WidgetTester tester ) async{

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.catching_pokemon),
                ),
                title: const Text('Pikachu'),
                subtitle: const Text('#025'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: (){},
              )
            ),
          ),
        ),
      );

      expect(find.text('Pikachu'),findsOneWidget);
      expect(find.text('#025'),findsOneWidget);
      expect(find.byIcon(Icons.catching_pokemon),findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward),findsOneWidget);
    } );

    testWidgets('Pokemon card is tappable',(WidgetTester tester) async{
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold (
            body:Card(
              child:ListTile(
                leading: const CircleAvatar(
                  child:Icon(Icons.catching_pokemon),
                ),
                title: const Text (' Pikachu'),
                subtitle: const Text('#025'),
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('Pokemon list shows more then 1 card',(WidgetTester tester) async{

      final pokemonList = [
        {'name':'Pikachu','id': '#025'},
        {'name':'Bulbasaur','id': '#001'},
        {'name':'Charmander', 'id':'#004'},
        {'name':'Squirtle','id': '#007'},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home:Scaffold(
            body:ListView.builder(
              itemCount: pokemonList.length,
              itemBuilder:(context,index){
                final pokemon = pokemonList[index];
                return Card(
                  child:ListTile(
                    title: Text(pokemon['name']!),
                    subtitle: Text(pokemon['id']!),
                  ),
                );
              },
            )
          )
        ),
      );

      expect(find.text('Bulbasaur'), findsOneWidget);
      expect(find.text('Charmander'), findsOneWidget);
      expect(find.text('Pikachu'), findsOneWidget);
      expect(find.text('Squirtle'), findsOneWidget);
      
    });
  });
}