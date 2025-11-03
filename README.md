lbd_phone_input (Flutter)
=========================

> **Sponsored by [Transfeero](https://www.transfeero.com)**, the premium airport transfer platform.

Ultra-flexible, accessible phone-input widgets for Flutter with geo-aware defaults, smart formatting, and backend-friendly payloads. This package is a faithful port of the original **lbd-phone-input** web library, rebuilt with Flutter idioms while keeping feature parity and API familiarity.

- **Requirements:** Dart 3.2+ · Flutter 3.16+

- 118 country definitions with realistic placeholders and masks
- Emoji or custom flag rendering and geo-smart defaults
- Auto-formatting and national-mode helpers
- Complete controller API for manual integrations
- Built-in translations for 10 languages (customizable)

Table of contents
-----------------

1. [Installation](#installation)
2. [Concepts](#concepts)
3. [Quick start](#quick-start)
4. [Controller API](#controller-api)
5. [Widget usage](#widget-usage)
6. [Configuration reference](#configuration-reference)
7. [Localization](#localization)
8. [Country dataset](#country-dataset)
9. [Utility helpers](#utility-helpers)
10. [Testing](#testing)
11. [Example app](#example-app)
12. [Migration tips](#migration-tips)
13. [Sponsor](#sponsor)

Installation
------------

```yaml
dependencies:
  lbd_phone_input: ^0.1.0
```

For local development inside this repository, reference the path instead:

```yaml
dependencies:
  lbd_phone_input:
    path: ..
```

Run `flutter pub get` afterwards.

Concepts
--------

| Term | Description |
| --- | --- |
| `LbdPhoneInputController` | Core state manager. Formats values, exposes payloads, and drives the widget. |
| `LbdPhoneInput` | Material widget that wires the controller to an interactive UI (dial selector + text field). |
| `PhoneInputOptions` | Immutable configuration for dataset, formatting, localization, theming, bindings, etc. |
| `PhoneInputState` | Snapshot emitted on every change with country, formatted value, digits, E.164, theme. |
| `PhonePayloadMode` | Chooses the shape of the payload (`split`, `combined`, or `both`). |

Quick start
-----------

```dart
import 'package:flutter/material.dart';
import 'package:lbd_phone_input/lbd_phone_input.dart';

class BookingPhoneField extends StatefulWidget {
  const BookingPhoneField({super.key});

  @override
  State<BookingPhoneField> createState() => _BookingPhoneFieldState();
}

class _BookingPhoneFieldState extends State<BookingPhoneField> {
  late final LbdPhoneInputController controller;

  @override
  void initState() {
    super.initState();
    controller = LbdPhoneInputController(
      options: const PhoneInputOptions(
        preferredCountries: ['it', 'us', 'gb'],
        smartPlaceholder: true,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LbdPhoneInput(
      controller: controller,
      onChanged: (state) {
        debugPrint('Dial: ${state.dialCode}');
        debugPrint('National: ${state.nationalNumber}');
        debugPrint('E.164: ${state.e164}');
      },
    );
  }
}
```

Controller API
--------------

```dart
final controller = LbdPhoneInputController();

// Read state
final state = controller.state;
state.country;          // Selected Country object
state.formattedValue;   // e.g. "+39 347 12 34 567"
state.nationalNumber;   // Digits only
state.e164;             // "+393471234567"
state.theme;            // Brightness.light / dark

// Query helpers
controller.getDialCode();           // "+39"
controller.getNationalNumber();     // "3471234567"
controller.getState();              // same as controller.state

// Mutation helpers
controller.setCountry('us');
controller.setValue(
  const PhoneInputInitialValue(
    combined: '+1 202 555 0101',
  ),
);
controller.setTheme(PhoneInputTheme.dark);
controller.applyBrightness(Brightness.light); // when theme == auto

// Payload helpers
final splitPayload = controller.getPayload(); // PhoneInputPayload
final combined = controller.getPayload(PhonePayloadMode.combined) as String;
final withCombined =
    controller.getPayload(PhonePayloadMode.both) as PhoneInputPayloadWithCombined;

// Formatting & search
controller.format('3471234567');              // "+39 347 123 4567"
controller.searchCountries('united');         // List<Country>
```

Widget usage
------------

`LbdPhoneInput` renders:

- Flag selector button (`emoji`, `sprite`, or hidden)
- Drop-down modal with search, keyboard navigation, and ARIA semantics
- Text field with auto-formatting masks
- Optional `onChanged` callback, reusing the controller’s state emission

Common patterns:

```dart
LbdPhoneInput(
  controller: controller,
  enabled: true,
  selectorPadding: const EdgeInsets.symmetric(horizontal: 12),
  decoration: const InputDecoration(
    labelText: 'Phone number',
    border: OutlineInputBorder(),
  ),
  focusNode: focusNode,
  onChanged: (state) => print(state.e164),
);
```

Controller-less usage (widget owns internal controller):

```dart
const LbdPhoneInput(
  options: PhoneInputOptions(
    defaultCountry: 'fr',
    nationalMode: true,
  ),
);
```

Configuration reference
-----------------------

All properties in `PhoneInputOptions` (defaults shown):

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `countries` | `List<CountryDefinition>` | Bundled dataset | Override with your own list. |
| `preferredCountries` | `List<String>` | `['it', 'us', 'gb', 'fr', 'de']` | Pinned to top of selector. |
| `defaultCountry` | `String` | `'it'` | ISO2 used on init. |
| `autoFormat` | `bool` | `true` | Apply masking as you type. |
| `nationalMode` | `bool` | `false` | Show national number only (no `+` dial code). |
| `smartPlaceholder` | `bool` | `true` | Use realistic placeholder per country. |
| `disableDialCodeInsertion` | `bool` | `false` | Prevent dial code in the input when typing. |
| `preventInvalidDialCode` | `bool` | `true` | Normalizes and guards dial code in combined mode. |
| `flagDisplay` | `FlagDisplayMode` | `emoji` | `emoji`, `sprite`, or `none`. |
| `flagSpriteUrl` | `String?` | `null` | Base sprite sheet. |
| `flagSpriteRetinaUrl` | `String?` | `null` | 2x sprite sheet. |
| `closeDropdownOnSelection` | `bool` | `true` | Keep modal open when `false`. |
| `theme` | `PhoneInputTheme` | `auto` | `light`, `dark`, or `auto`. |
| `language` | `String` | `'en'` | Language code for translations. |
| `translationsOverrides` | `Map<String, String>` | `{}` | Inline copy overrides. |
| `value` | `PhoneInputInitialValue?` | `null` | Pre-populate the controller. |
| `searchPlaceholder` | `String?` | `null` | Custom search hint. |
| `dropdownPlaceholder` | `String?` | `null` | Text shown above country list. |
| `ariaLabelSelector` | `String?` | `null` | Accessible label for selector button. |
| `onChanged` | `PhoneInputChangeCallback?` | `null` | Additional callback in options-only controller setups. |

`PhoneInputInitialValue` accepts `dialCode`, `nationalNumber`, and/or `combined`. The controller will deduce missing parts (e.g. derive national number from combined).

Localization
------------

The library ships with translations for **en**, **it**, **es**, **fr**, **de**, **pt**, **ru**, **zh**, **ja**, **ar**. Example:

```dart
LbdPhoneInputController(
  options: const PhoneInputOptions(
    language: 'it',
    translationsOverrides: {
      'searchPlaceholder': 'Cerca prefisso',
    },
  ),
);
```

Country dataset
---------------

- 118 `CountryDefinition` entries (see `lib/src/country_data.dart`)
- Each entry includes `mask` (e.g. `(###) ###-####`) and `example` placeholder
- Derived `Country` model adds `flag` (emoji) and `priority` for sorting

Use custom data:

```dart
const customCountries = [
  CountryDefinition(
    iso2: 'va',
    name: 'Vatican City',
    dialCode: '+379',
    mask: '### ####',
  ),
];

LbdPhoneInputController(
  options: const PhoneInputOptions(
    countries: customCountries,
    preferredCountries: ['va'],
  ),
);
```

Utility helpers
---------------

`lib/src/utils.dart` exposes internally:

- `sanitizeValue`, `extractDigits`
- `formatWithMask`
- `normalizeDialCode`, `ensureLeadingPlus`
- `guessCountryFromInput`, `findCountryByDialCode`
- `splitNumber` → `SplitNumberResult`
- `buildSearchIndex`, `filterCountries`

These are intentionally not exported to keep the public API focused on controller + widget usage.

Testing
-------

- Widget and controller tests live in `test/`
- Run `flutter test` from the project root
- Example coverage:
  - `phone_input_controller_test.dart` verifies formatting, payloads, theme switching, search
  - `phone_input_widget_test.dart` exercises modal selection and callback wiring

Example app
-----------

A fully wired showcase is under `example/` with buttons demonstrating every controller method. Launch it with:

```bash
cd example
flutter create . --platforms=ios,android  # first time only
flutter run
```

Use the on-screen buttons to invoke `setCountry`, `setValue`, `setTheme`, inspect payloads, and observe national-mode behaviour.

Migration tips
--------------

Porting from the TypeScript widget:

- Replace DOM bindings with `LbdPhoneInputController`
- Move event handlers to `onChanged`
- Use `PhonePayloadMode` to match backend expectations
- `flagDisplay: FlagDisplayMode.none` mimics sprite-free setups; provide sprites via `flagSpriteUrl` to mirror the web version
- `nationalMode: true` replicates split-input behaviour; combine with two text fields as needed

Sponsor
-------

`lbd_phone_input` is maintained and proudly sponsored by [Transfeero](https://www.transfeero.com). Building something great with the widget? Let us know!
