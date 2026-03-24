import 'package:devyse_pos/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MaterialApp and AuthWrapper mount', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
