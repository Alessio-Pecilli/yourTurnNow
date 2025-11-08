import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_turn/src/models/roommate.dart';
import 'package:your_turn/src/widgets/profile_header.dart';

void main() {
  testWidgets('ProfileHeader si costruisce senza errori', (tester) async {
    final roommate = Roommate(id: '1', name: 'Ale');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileHeader(
            roommate: Roommate(id: '1', name: 'Ale'),
          ),
        ),
      ),
    );

    expect(find.byType(ProfileHeader), findsOneWidget);
  });
}
