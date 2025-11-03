import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lbd_phone_input/lbd_phone_input.dart';

void main() {
  group('LbdPhoneInputController', () {
    test('uses default country and placeholder on init', () {
      final controller = LbdPhoneInputController();

      expect(controller.country.iso2, 'it');
      expect(controller.state.dialCode, '+39');
      expect(controller.placeholder, isNotNull);
      expect(controller.placeholder!.isNotEmpty, isTrue);

      controller.dispose();
    });

    test('setValue with combined number infers country and payload', () {
      final controller = LbdPhoneInputController();

      controller.setValue(
        const PhoneInputInitialValue(combined: '+1 202 555 0101'),
      );

      final state = controller.state;
      expect(state.country.iso2, 'us');
      expect(state.nationalNumber, '2025550101');
      expect(state.e164, '+12025550101');

      final splitPayload = controller.getPayload();
      expect(splitPayload, isA<PhoneInputPayload>());

      final combinedPayload =
          controller.getPayload(PhonePayloadMode.combined) as String;
      expect(combinedPayload, '+12025550101');

      final bothPayload = controller.getPayload(PhonePayloadMode.both);
      expect(bothPayload, isA<PhoneInputPayloadWithCombined>());
      expect(
        (bothPayload as PhoneInputPayloadWithCombined).combined,
        '+12025550101',
      );

      controller.dispose();
    });

    test('setCountry updates placeholder and formatting', () {
      final controller = LbdPhoneInputController();
      final originalPlaceholder = controller.placeholder;

      controller.setCountry('fr');
      expect(controller.country.iso2, 'fr');
      expect(controller.placeholder, isNot(originalPlaceholder));

      controller.dispose();
    });

    test('setTheme switches brightness in emitted state', () {
      final controller = LbdPhoneInputController();

      controller.setTheme(PhoneInputTheme.dark);
      expect(controller.state.theme, Brightness.dark);

      controller.setTheme(PhoneInputTheme.light);
      expect(controller.state.theme, Brightness.light);

      controller.dispose();
    });

    test('searchCountries returns matches by name or dial code', () {
      final controller = LbdPhoneInputController();

      final byName = controller.searchCountries('Italy');
      expect(byName.map((c) => c.iso2), contains('it'));

      final byDial = controller.searchCountries('+44');
      expect(byDial.map((c) => c.iso2), contains('gb'));

      controller.dispose();
    });
  });
}
