import 'package:flutter/material.dart';

import 'country_data.dart';
import 'models.dart';
import 'translations.dart';
import 'utils.dart';

class LbdPhoneInputController extends ChangeNotifier {
  LbdPhoneInputController({
    PhoneInputOptions options = const PhoneInputOptions(),
    PhoneInputInitialValue? initialValue,
  }) : _options = options {
    final definitions = (options.countries.isNotEmpty
            ? options.countries
            : kDefaultCountries)
        .asMap()
        .entries
        .map((entry) => entry.value.toCountry(priority: entry.key))
        .toList();
    definitions.sort((a, b) => a.name.compareTo(b.name));
    _countries = flagSort(options.preferredCountries, definitions);
    _searchIndex = buildSearchIndex(_countries);
    _themeMode = options.theme;
    _resolvedTheme = _themeMode == PhoneInputTheme.dark
        ? Brightness.dark
        : Brightness.light;
    _translations =
        resolveTranslations(options.language, options.translationsOverrides);
    _translations = _translations.copyWith(
      searchPlaceholder: options.searchPlaceholder,
      dropdownPlaceholder: options.dropdownPlaceholder,
      ariaLabelSelector: options.ariaLabelSelector,
    );

    _selectedCountry = resolveCountry(
      options.defaultCountry,
      _countries,
      _countries.first,
    );
    _textController = TextEditingController();
    _textController.addListener(_handleTextChanged);

    _applyInitialValue(initialValue ?? options.value);
    _updatePlaceholder();
    _emitState();
  }

  late TextEditingController _textController;
  late List<Country> _countries;
  late List<CountrySearchEntry> _searchIndex;
  late Country _selectedCountry;
  late PhoneInputTranslations _translations;
  late PhoneInputTheme _themeMode;
  Brightness _resolvedTheme = Brightness.light;
  String _lastCommittedValue = '';
  String _lastDigits = '';
  bool _isApplying = false;
  PhoneInputOptions _options;
  PhoneInputState? _state;
  String? _placeholder;

  TextEditingController get textController => _textController;

  List<Country> get countries => _countries;

  Country get country => _selectedCountry;

  Country getCountry() => _selectedCountry;

  PhoneInputOptions get options => _options;

  PhoneInputState get state =>
      _state ??
      PhoneInputState(
        country: _selectedCountry,
        formattedValue: '',
        rawValue: '',
        nationalNumber: '',
        dialCode: _selectedCountry.dialCode,
        e164: '',
        isValid: false,
        theme: _resolvedTheme,
      );

  PhoneInputTranslations get translations => _translations;

  String? get placeholder => _placeholder;

  PhoneInputState getState() => state;

  String getDialCode() => _selectedCountry.dialCode;

  String getNationalNumber() => extractDigits(_textController.text);

  void updateOptions(PhoneInputOptions options) {
    _options = options;
    final previousCountryIso = _selectedCountry.iso2;
    final definitions = (options.countries.isNotEmpty
            ? options.countries
            : kDefaultCountries)
        .asMap()
        .entries
        .map((entry) => entry.value.toCountry(priority: entry.key))
        .toList();
    definitions.sort((a, b) => a.name.compareTo(b.name));
    _countries = flagSort(options.preferredCountries, definitions);
    _searchIndex = buildSearchIndex(_countries);
    _translations =
        resolveTranslations(options.language, options.translationsOverrides)
            .copyWith(
      searchPlaceholder: options.searchPlaceholder,
      dropdownPlaceholder: options.dropdownPlaceholder,
      ariaLabelSelector: options.ariaLabelSelector,
    );
    _selectedCountry = resolveCountry(
      previousCountryIso,
      _countries,
      _countries.first,
    );
    _themeMode = options.theme;
    if (_themeMode == PhoneInputTheme.light) {
      _resolvedTheme = Brightness.light;
    } else if (_themeMode == PhoneInputTheme.dark) {
      _resolvedTheme = Brightness.dark;
    }
    if (options.value != null) {
      _applyInitialValue(options.value);
    } else {
      _applyMask();
    }
    _updatePlaceholder();
    _emitState(notify: true);
  }

  void applyBrightness(Brightness brightness) {
    if (_themeMode != PhoneInputTheme.auto || _resolvedTheme == brightness) {
      return;
    }
    _resolvedTheme = brightness;
    _emitState();
  }

  void setTheme(PhoneInputTheme theme) {
    if (_themeMode == theme) {
      return;
    }
    _themeMode = theme;
    switch (theme) {
      case PhoneInputTheme.auto:
        break;
      case PhoneInputTheme.light:
        _resolvedTheme = Brightness.light;
        break;
      case PhoneInputTheme.dark:
        _resolvedTheme = Brightness.dark;
        break;
    }
    _emitState();
  }

  void setCountry(String iso2) {
    final resolved = resolveCountry(iso2, _countries, _selectedCountry);
    if (resolved.iso2 == _selectedCountry.iso2) {
      return;
    }
    _selectedCountry = resolved;
    _updatePlaceholder();
    _applyMask();
    _emitState(notify: true);
  }

  void setValue(PhoneInputInitialValue value) {
    _applyInitialValue(value);
    _emitState(notify: true);
  }

  Object getPayload([PhonePayloadMode mode = PhonePayloadMode.split]) {
    final current = state;
    final combined =
        current.e164.isNotEmpty ? current.e164 : current.formattedValue;
    switch (mode) {
      case PhonePayloadMode.combined:
        return combined;
      case PhonePayloadMode.split:
        return current.toPayload();
      case PhonePayloadMode.both:
        return PhoneInputPayloadWithCombined(
          dialCode: current.dialCode,
          nationalNumber: current.nationalNumber,
          formattedValue: current.formattedValue,
          e164: current.e164,
          combined: combined,
        );
    }
  }

  String format(String value) {
    final digits = extractDigits(value);
    final formatted = _options.autoFormat
        ? formatWithMask(_selectedCountry.mask, digits)
        : digits;
    if (_options.nationalMode) {
      return formatted;
    }
    return digits.isEmpty
        ? ''
        : '${_selectedCountry.dialCode} ${formatted.trim()}'.trim();
  }

  List<Country> searchCountries(String query) {
    return filterCountries(query, _searchIndex);
  }

  @override
  void dispose() {
    _textController.removeListener(_handleTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _applyInitialValue(PhoneInputInitialValue? value) {
    final incoming = value ?? const PhoneInputInitialValue();
    var country = _selectedCountry;
    if (incoming.dialCode != null && incoming.dialCode!.isNotEmpty) {
      country = findCountryByDialCode(
        incoming.dialCode,
        _countries,
        country,
      );
    } else if (incoming.combined != null &&
        incoming.combined!.trim().isNotEmpty) {
      country = guessCountryFromInput(
        incoming.combined!,
        _countries,
        country,
      );
    }

    _selectedCountry = country;

    String national = (incoming.nationalNumber ?? '').trim();
    if (national.isEmpty && (incoming.combined?.isNotEmpty ?? false)) {
      final split = splitNumber(incoming.combined!, country);
      national = split.nationalNumber;
    }
    if (national.isEmpty && (incoming.dialCode?.isNotEmpty ?? false)) {
      final split = splitNumber(
        '${incoming.dialCode}${incoming.nationalNumber ?? ''}',
        country,
      );
      national = split.nationalNumber;
    }

    final digits = extractDigits(national);
    final formatted = _options.autoFormat
        ? formatWithMask(country.mask, digits)
        : digits;
    _isApplying = true;
    _textController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    _isApplying = false;
    _lastCommittedValue = formatted;
  }

  void _handleTextChanged() {
    if (_isApplying) {
      return;
    }
    final rawInput = _textController.text;
    final previousDigits = _lastDigits;
    final previousFormatted = _lastCommittedValue;

    var digits = extractDigits(rawInput);

    final removedFormattingOnly = rawInput.length < previousFormatted.length &&
        digits == previousDigits &&
        previousDigits.isNotEmpty;
    if (removedFormattingOnly) {
      digits = previousDigits.substring(0, previousDigits.length - 1);
    }

    final formatted = _options.autoFormat
        ? formatWithMask(_selectedCountry.mask, digits)
        : digits;
    if (formatted != rawInput) {
      _isApplying = true;
      _textController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      _isApplying = false;
    }

    if (formatted != _lastCommittedValue || digits != previousDigits) {
      _lastCommittedValue = formatted;
      _emitState();
    }
  }

  void _applyMask() {
    final rawDigits = extractDigits(_textController.text);
    final formatted = _options.autoFormat
        ? formatWithMask(_selectedCountry.mask, rawDigits)
        : rawDigits;
    _isApplying = true;
    _textController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    _isApplying = false;
    _lastCommittedValue = formatted;
  }

  void _updatePlaceholder() {
    if (!_options.smartPlaceholder) {
      _placeholder = null;
      return;
    }
    _placeholder = _selectedCountry.example;
  }

  void _emitState({bool notify = true}) {
    final displayValue = _textController.text;
    final digits = extractDigits(displayValue);
    final formattedNational = _options.autoFormat
        ? formatWithMask(_selectedCountry.mask, digits)
        : digits;
    final dialCode = _selectedCountry.dialCode;
    final formattedValue = _options.nationalMode
        ? formattedNational
        : digits.isEmpty
            ? ''
            : '$dialCode $formattedNational'.trim();
    final payload = PhoneInputState(
      country: _selectedCountry,
      formattedValue: formattedValue,
      rawValue: displayValue,
      nationalNumber: digits,
      dialCode: dialCode,
      e164: toE164(dialCode, digits),
      isValid: digits.length >= 6,
      theme: _resolvedTheme,
    );
    _state = payload;
    _lastDigits = digits;
    if (_options.onChanged != null) {
      _options.onChanged!(payload);
    }
    if (notify) {
      notifyListeners();
    }
  }
}
