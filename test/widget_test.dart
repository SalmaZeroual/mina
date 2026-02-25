import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Pour ProviderScope
import 'package:mina/app.dart'; // Importez le fichier où se trouve MinaApp

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // On construit l'app enveloppée dans le scope de Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: MinaApp(),
      ),
    );

    // Vérification initiale
    expect(find.text('0'), findsOneWidget);

    // Simulation du clic
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Vérification finale
    expect(find.text('1'), findsOneWidget);
  });
}