import 'dart:math';

import 'models.dart';

final RegExp _digitRegex = RegExp(r'\d');

String sanitizeValue(String value) {
  return value.replaceAll(RegExp(r'[^\d+]'), '');
}

String extractDigits(String value) {
  return value.splitMapJoin(
    _digitRegex,
    onMatch: (match) => match.group(0)!,
    onNonMatch: (_) => '',
  );
}

String formatWithMask(String? mask, String digits) {
  if (mask == null || mask.isEmpty) {
    return digits;
  }
  if (digits.isEmpty) {
    return '';
  }
  var digitIndex = 0;
  final buffer = StringBuffer();
  for (var i = 0; i < mask.length; i += 1) {
    final token = mask[i];
    if (token == '#') {
      if (digitIndex < digits.length) {
        buffer.write(digits[digitIndex]);
        digitIndex += 1;
      } else {
        buffer.write('_');
      }
    } else {
      buffer.write(token);
    }
  }
  final formatted = buffer.toString();
  final placeholderIndex = formatted.indexOf('_');
  return placeholderIndex >= 0
      ? formatted.substring(0, placeholderIndex)
      : formatted;
}

String ensureLeadingPlus(String value) {
  if (value.isEmpty) {
    return '';
  }
  return value.startsWith('+') ? value : '+$value';
}

String normalizeDialCode(String? value) {
  if (value == null) {
    return '';
  }
  final digits = extractDigits(value);
  return digits.isEmpty ? '' : '+$digits';
}

List<Country> flagSort(List<String>? preferred, List<Country> countries) {
  if (preferred == null || preferred.isEmpty) {
    return List<Country>.from(countries);
  }
  final preferredCountries = <Country>[];
  final lowerPreferred = preferred.map((iso) => iso.toLowerCase()).toSet();
  for (final iso in preferred) {
    final lower = iso.toLowerCase();
    final match = _findCountry(countries, lower);
    if (match != null) {
      preferredCountries.add(match);
    }
  }
  final remainingCountries = countries
      .where((country) => !lowerPreferred.contains(country.iso2.toLowerCase()))
      .toList(growable: false);
  return [...preferredCountries, ...remainingCountries];
}

Country? _findCountry(List<Country> countries, String lowerIso) {
  for (final country in countries) {
    if (country.iso2.toLowerCase() == lowerIso) {
      return country;
    }
  }
  return null;
}

Country resolveCountry(
  String? iso2,
  List<Country> countries,
  Country fallback,
) {
  if (iso2 == null) {
    return fallback;
  }
  final lower = iso2.toLowerCase();
  return countries.firstWhere(
    (country) => country.iso2.toLowerCase() == lower,
    orElse: () => fallback,
  );
}

Country findCountryByDialCode(
  String? dialCode,
  List<Country> countries,
  Country fallback,
) {
  final normalized = normalizeDialCode(dialCode);
  if (normalized.isEmpty) {
    return fallback;
  }
  return countries.firstWhere(
    (country) => normalizeDialCode(country.dialCode) == normalized,
    orElse: () => fallback,
  );
}

Country guessCountryFromInput(
  String value,
  List<Country> countries,
  Country fallback,
) {
  final sanitized = sanitizeValue(value);
  if (!sanitized.startsWith('+')) {
    return fallback;
  }
  for (var length = 1; length <= 4; length += 1) {
    final prefix = sanitized.substring(0, min(length + 1, sanitized.length));
    final match = countries.firstWhere(
      (country) => country.dialCode == prefix,
      orElse: () => fallback,
    );
    if (match != fallback) {
      return match;
    }
  }
  return fallback;
}

String toE164(String dialCode, String nationalNumber) {
  final dialDigits = extractDigits(ensureLeadingPlus(dialCode));
  final numberDigits = extractDigits(nationalNumber);
  final combined = '$dialDigits$numberDigits';
  return combined.isEmpty ? '' : '+$combined';
}

SplitNumberResult splitNumber(
  String value,
  Country country,
) {
  final digits = extractDigits(value);
  final dialDigits = extractDigits(country.dialCode);
  if (!digits.startsWith(dialDigits)) {
    return SplitNumberResult(
      dialCode: country.dialCode,
      nationalNumber: digits,
    );
  }
  return SplitNumberResult(
    dialCode: country.dialCode,
    nationalNumber: digits.substring(dialDigits.length),
  );
}

List<CountrySearchEntry> buildSearchIndex(List<Country> countries) {
  return countries
      .map(
        (country) => CountrySearchEntry(
          country: country,
          haystack: [
            country.name.toLowerCase(),
            country.iso2.toLowerCase(),
            country.dialCode.replaceAll('+', ''),
            country.dialCode,
          ].join(' '),
        ),
      )
      .toList(growable: false);
}

List<Country> filterCountries(
  String query,
  List<CountrySearchEntry> index,
) {
  final sanitized = query.trim().toLowerCase();
  if (sanitized.isEmpty) {
    return index.map((entry) => entry.country).toList(growable: false);
  }
  return index
      .where((entry) => entry.haystack.contains(sanitized))
      .map((entry) => entry.country)
      .toList(growable: false);
}

String isoToFlagEmoji(String iso) {
  return iso
      .toUpperCase()
      .split('')
      .map((char) => String.fromCharCode(char.codeUnitAt(0) + 127397))
      .join();
}

class CountrySearchEntry {
  const CountrySearchEntry({required this.country, required this.haystack});

  final Country country;
  final String haystack;
}

class SplitNumberResult {
  const SplitNumberResult({
    required this.dialCode,
    required this.nationalNumber,
  });

  final String dialCode;
  final String nationalNumber;
}
