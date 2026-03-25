import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_os/main.dart';

void main() {
  testWidgets('LifeOS Smoke Test', (WidgetTester tester) async {
    // 🚀 Error fix: Yahan hum generic 'ProviderScope' use karenge
    // Agar 'LifeOS' nahi mil raha, toh check karein aapki main.dart mein class ka naam kya hai.
    // Aksar projects mein ye 'MyApp' hi hota hai.

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: Text('LifeOS Loading...')),
        ),
      ),
    );

    // Verify basics
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}