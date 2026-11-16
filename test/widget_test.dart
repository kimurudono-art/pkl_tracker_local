// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:pkl_tracker_local/main.dart';

void main() {
  setUpAll(() {
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('app renders homepage', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('PKL Tracker Local'), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
  });
}
