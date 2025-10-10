import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_turn/src/widgets/profile_header.dart';
import 'package:your_turn/src/models/roommate.dart';

void main() {
  group('ProfileHeader Widget Tests', () {

    testWidgets('deve renderizzare widget base', (tester) async {
      final roommate = Roommate(id: '1', name: 'Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileHeader(
              roommate: roommate,
              
            ),
          ),
        ),
      );

      // Test semplici - solo che i pulsanti esistano
      expect(find.text('Download'), findsOneWidget);
      expect(find.text('Aggiungi'), findsOneWidget);
    });
  });
}