import 'package:flutter/material.dart';

@immutable
class CountryDefinition {
  const CountryDefinition({
    required this.iso2,
    required this.name,
    required this.dialCode,
    this.mask,
    this.example,
  });

  final String iso2;
  final String name;
  final String dialCode;
  final String? mask;
  final String? example;

  Country toCountry({required int priority}) {
    return Country(
      iso2: iso2,
      name: name,
      dialCode: dialCode,
      mask: mask,
      example: example,
      flag: _isoToFlagEmoji(iso2),
      priority: priority,
    );
  }
}

@immutable
class Country {
  const Country({
    required this.iso2,
    required this.name,
    required this.dialCode,
    required this.flag,
    required this.priority,
    this.mask,
    this.example,
  });

  final String iso2;
  final String name;
  final String dialCode;
  final String flag;
  final int priority;
  final String? mask;
  final String? example;
}

enum FlagDisplayMode { emoji, sprite, none }

enum PhoneInputTheme { light, dark, auto }

@immutable
class PhoneInputInitialValue {
  const PhoneInputInitialValue({
    this.dialCode,
    this.nationalNumber,
    this.combined,
  });

  final String? dialCode;
  final String? nationalNumber;
  final String? combined;
}

typedef PhoneInputChangeCallback = void Function(PhoneInputState state);

@immutable
class PhoneInputOptions {
  const PhoneInputOptions({
    this.countries = const [],
    this.preferredCountries = const ['it', 'us', 'gb', 'fr', 'de'],
    this.defaultCountry = 'it',
    this.autoFormat = true,
    this.nationalMode = false,
    this.smartPlaceholder = true,
    this.disableDialCodeInsertion = false,
    this.preventInvalidDialCode = true,
    this.flagDisplay = FlagDisplayMode.emoji,
    this.flagSpriteUrl,
    this.flagSpriteRetinaUrl,
    this.closeDropdownOnSelection = true,
    this.theme = PhoneInputTheme.auto,
    this.language = 'en',
    this.translationsOverrides = const {},
    this.value,
    this.searchPlaceholder,
    this.dropdownPlaceholder,
    this.ariaLabelSelector,
    this.onChanged,
  });

  final List<CountryDefinition> countries;
  final List<String> preferredCountries;
  final String defaultCountry;
  final bool autoFormat;
  final bool nationalMode;
  final bool smartPlaceholder;
  final bool disableDialCodeInsertion;
  final bool preventInvalidDialCode;
  final FlagDisplayMode flagDisplay;
  final String? flagSpriteUrl;
  final String? flagSpriteRetinaUrl;
  final bool closeDropdownOnSelection;
  final PhoneInputTheme theme;
  final String language;
  final Map<String, String> translationsOverrides;
  final PhoneInputInitialValue? value;
  final String? searchPlaceholder;
  final String? dropdownPlaceholder;
  final String? ariaLabelSelector;
  final PhoneInputChangeCallback? onChanged;

  PhoneInputOptions copyWith({
    List<CountryDefinition>? countries,
    List<String>? preferredCountries,
    String? defaultCountry,
    bool? autoFormat,
    bool? nationalMode,
    bool? smartPlaceholder,
    bool? disableDialCodeInsertion,
    bool? preventInvalidDialCode,
    FlagDisplayMode? flagDisplay,
    String? flagSpriteUrl,
    String? flagSpriteRetinaUrl,
    bool? closeDropdownOnSelection,
    PhoneInputTheme? theme,
    String? language,
    Map<String, String>? translationsOverrides,
    PhoneInputInitialValue? value,
    String? searchPlaceholder,
    String? dropdownPlaceholder,
    String? ariaLabelSelector,
    PhoneInputChangeCallback? onChanged,
  }) {
    return PhoneInputOptions(
      countries: countries ?? this.countries,
      preferredCountries: preferredCountries ?? this.preferredCountries,
      defaultCountry: defaultCountry ?? this.defaultCountry,
      autoFormat: autoFormat ?? this.autoFormat,
      nationalMode: nationalMode ?? this.nationalMode,
      smartPlaceholder: smartPlaceholder ?? this.smartPlaceholder,
      disableDialCodeInsertion:
          disableDialCodeInsertion ?? this.disableDialCodeInsertion,
      preventInvalidDialCode:
          preventInvalidDialCode ?? this.preventInvalidDialCode,
      flagDisplay: flagDisplay ?? this.flagDisplay,
      flagSpriteUrl: flagSpriteUrl ?? this.flagSpriteUrl,
      flagSpriteRetinaUrl: flagSpriteRetinaUrl ?? this.flagSpriteRetinaUrl,
      closeDropdownOnSelection:
          closeDropdownOnSelection ?? this.closeDropdownOnSelection,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      translationsOverrides:
          translationsOverrides ?? this.translationsOverrides,
      value: value ?? this.value,
      searchPlaceholder: searchPlaceholder ?? this.searchPlaceholder,
      dropdownPlaceholder: dropdownPlaceholder ?? this.dropdownPlaceholder,
      ariaLabelSelector: ariaLabelSelector ?? this.ariaLabelSelector,
      onChanged: onChanged ?? this.onChanged,
    );
  }
}

@immutable
class PhoneInputState {
  const PhoneInputState({
    required this.country,
    required this.formattedValue,
    required this.rawValue,
    required this.nationalNumber,
    required this.dialCode,
    required this.e164,
    required this.isValid,
    required this.theme,
  });

  final Country country;
  final String formattedValue;
  final String rawValue;
  final String nationalNumber;
  final String dialCode;
  final String e164;
  final bool isValid;
  final Brightness theme;

  PhoneInputPayload toPayload() {
    return PhoneInputPayload(
      dialCode: dialCode,
      nationalNumber: nationalNumber,
      formattedValue: formattedValue,
      e164: e164,
    );
  }
}

@immutable
class PhoneInputPayload {
  const PhoneInputPayload({
    required this.dialCode,
    required this.nationalNumber,
    required this.formattedValue,
    required this.e164,
  });

  final String dialCode;
  final String nationalNumber;
  final String formattedValue;
  final String e164;
}

enum PhonePayloadMode { combined, split, both }

class PhoneInputPayloadWithCombined extends PhoneInputPayload {
  const PhoneInputPayloadWithCombined({
    required super.dialCode,
    required super.nationalNumber,
    required super.formattedValue,
    required super.e164,
    required this.combined,
  });

  final String combined;
}

String _isoToFlagEmoji(String iso) {
  return iso
      .toUpperCase()
      .split('')
      .map((char) => String.fromCharCode(char.codeUnitAt(0) + 127397))
      .join();
}
