class PhoneInputTranslations {
  const PhoneInputTranslations({
    required this.searchPlaceholder,
    required this.dropdownPlaceholder,
    required this.ariaLabelSelector,
    required this.noResults,
  });

  final String searchPlaceholder;
  final String dropdownPlaceholder;
  final String ariaLabelSelector;
  final String noResults;

  PhoneInputTranslations copyWith({
    String? searchPlaceholder,
    String? dropdownPlaceholder,
    String? ariaLabelSelector,
    String? noResults,
  }) {
    return PhoneInputTranslations(
      searchPlaceholder: searchPlaceholder ?? this.searchPlaceholder,
      dropdownPlaceholder: dropdownPlaceholder ?? this.dropdownPlaceholder,
      ariaLabelSelector: ariaLabelSelector ?? this.ariaLabelSelector,
      noResults: noResults ?? this.noResults,
    );
  }
}

const Map<String, PhoneInputTranslations> _baseTranslations = {
  'en': PhoneInputTranslations(
    searchPlaceholder: 'Search country or code',
    dropdownPlaceholder: 'Select a country',
    ariaLabelSelector: 'Select country dial code',
    noResults: 'No matches found',
  ),
  'it': PhoneInputTranslations(
    searchPlaceholder: 'Cerca paese o prefisso',
    dropdownPlaceholder: 'Seleziona un paese',
    ariaLabelSelector: 'Seleziona il prefisso internazionale',
    noResults: 'Nessun risultato',
  ),
  'es': PhoneInputTranslations(
    searchPlaceholder: 'Buscar país o código',
    dropdownPlaceholder: 'Selecciona un país',
    ariaLabelSelector: 'Selecciona el prefijo internacional',
    noResults: 'Sin coincidencias',
  ),
  'fr': PhoneInputTranslations(
    searchPlaceholder: 'Rechercher un pays ou un indicatif',
    dropdownPlaceholder: 'Sélectionner un pays',
    ariaLabelSelector: "Sélectionner l'indicatif international",
    noResults: 'Aucun résultat',
  ),
  'de': PhoneInputTranslations(
    searchPlaceholder: 'Land oder Vorwahl suchen',
    dropdownPlaceholder: 'Land auswählen',
    ariaLabelSelector: 'Ländervorwahl auswählen',
    noResults: 'Keine Treffer',
  ),
  'pt': PhoneInputTranslations(
    searchPlaceholder: 'Pesquisar país ou código',
    dropdownPlaceholder: 'Selecione um país',
    ariaLabelSelector: 'Selecione o código do país',
    noResults: 'Nenhum resultado',
  ),
  'ru': PhoneInputTranslations(
    searchPlaceholder: 'Поиск страны или кода',
    dropdownPlaceholder: 'Выберите страну',
    ariaLabelSelector: 'Выберите телефонный код',
    noResults: 'Ничего не найдено',
  ),
  'zh': PhoneInputTranslations(
    searchPlaceholder: '搜索国家或区号',
    dropdownPlaceholder: '选择国家',
    ariaLabelSelector: '选择国家区号',
    noResults: '没有匹配项',
  ),
  'ja': PhoneInputTranslations(
    searchPlaceholder: '国名または国番号を検索',
    dropdownPlaceholder: '国を選択',
    ariaLabelSelector: '国番号を選択',
    noResults: '一致する結果はありません',
  ),
  'ar': PhoneInputTranslations(
    searchPlaceholder: 'ابحث عن دولة أو رمز',
    dropdownPlaceholder: 'اختر الدولة',
    ariaLabelSelector: 'اختر رمز الدولة',
    noResults: 'لا توجد نتائج',
  ),
};

PhoneInputTranslations resolveTranslations(
  String? language,
  Map<String, String> overrides,
) {
  final normalized = (language ?? 'en').toLowerCase();
  final baseKey = normalized.split(RegExp(r'[\-_]')).first;
  final fallback = _baseTranslations['en']!;
  final base = _baseTranslations[baseKey] ?? fallback;
  return base.copyWith(
    searchPlaceholder: overrides['searchPlaceholder'],
    dropdownPlaceholder: overrides['dropdownPlaceholder'],
    ariaLabelSelector: overrides['ariaLabelSelector'],
    noResults: overrides['noResults'],
  );
}
