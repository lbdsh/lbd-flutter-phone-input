import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbd_phone_input/lbd_phone_input.dart';

void main() {
  testWidgets('LbdPhoneInput emits changes and updates UI on selection',
      (tester) async {
    PhoneInputState? lastState;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LbdPhoneInput(
            onChanged: (state) => lastState = state,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(lastState, isNotNull);
    expect(lastState!.country.iso2, 'it');
    expect(find.text('+39'), findsOneWidget);

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == 'Search country or code',
    );
    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'United');
    await tester.pumpAndSettle();

    await tester.tap(find.text('United States'));
    await tester.pumpAndSettle();

    expect(lastState!.country.iso2, 'us');
    expect(find.text('+1'), findsOneWidget);
  });
}
