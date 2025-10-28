// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calculator_app/main.dart';

void main() {
  testWidgets('Calculator UI Test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Kiểm tra có nút "1", "2" và "+"
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('+'), findsOneWidget);

    // Nhấn vào nút "1"
    await tester.tap(find.text('1'));
    await tester.pump();

    // Nhấn vào nút "+"
    await tester.tap(find.text('+'));
    await tester.pump();

    // Nhấn vào nút "2"
    await tester.tap(find.text('2'));
    await tester.pump();

    // Nhấn "="
    await tester.tap(find.text('='));
    await tester.pump();

    // Kiểm tra kết quả có hiển thị "3"
    expect(find.text('3'), findsOneWidget);
  });
}
