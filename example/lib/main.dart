import 'package:flutter/material.dart';
import 'package:lbd_phone_input/lbd_phone_input.dart';

void main() {
  runApp(const PhoneInputExampleApp());
}

class PhoneInputExampleApp extends StatelessWidget {
  const PhoneInputExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'lbd_phone_input example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const PhoneInputDemoPage(),
    );
  }
}

class PhoneInputDemoPage extends StatefulWidget {
  const PhoneInputDemoPage({super.key});

  @override
  State<PhoneInputDemoPage> createState() => _PhoneInputDemoPageState();
}

class _PhoneInputDemoPageState extends State<PhoneInputDemoPage> {
  late final LbdPhoneInputController _controller;
  late final LbdPhoneInputController _secondaryController;
  String _payloadCombined = '';
  PhoneInputPayload? _payloadSplit;
  String _formattedPreview = '';
  List<Country> _searchResults = const [];

  @override
  void initState() {
    super.initState();
    _controller = LbdPhoneInputController(
      options: const PhoneInputOptions(
        preferredCountries: ['it', 'us', 'gb'],
      ),
    );
    _secondaryController = LbdPhoneInputController(
      options: const PhoneInputOptions(
        defaultCountry: 'us',
        nationalMode: true,
        smartPlaceholder: false,
      ),
      initialValue: const PhoneInputInitialValue(
        dialCode: '+44',
        nationalNumber: '202555789',
      ),
    );

    _payloadCombined = _controller.getPayload(PhonePayloadMode.combined) as String;
    _payloadSplit = _controller.getPayload() as PhoneInputPayload;
    _formattedPreview = _controller.format('3391234567');
    _searchResults = _controller.searchCountries('united');
  }

  @override
  void dispose() {
    _controller.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('lbd_phone_input'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LbdPhoneInput(
              controller: _controller,
              onChanged: (next) {
                setState(() {});
                _payloadCombined =
                    _controller.getPayload(PhonePayloadMode.combined) as String;
                _payloadSplit = _controller.getPayload() as PhoneInputPayload;
                _formattedPreview = _controller.format('3391234567');
                _searchResults = _controller.searchCountries('united');
              },
            ),
            const SizedBox(height: 24),
            Text('Selected country: ${state.country.name}'),
            Text('Dial code: ${state.dialCode}'),
            Text('National number: ${state.nationalNumber}'),
            Text('Formatted: ${state.formattedValue}'),
            Text('E.164: ${state.e164.isEmpty ? '—' : state.e164}'),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Controller API',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('getState(): ${state.formattedValue}'),
            Text('getDialCode(): ${_controller.getDialCode()}'),
            Text('getNationalNumber(): ${_controller.getNationalNumber()}'),
            Text('format("3391234567"): $_formattedPreview'),
            Text('getPayload(split): ${_payloadSplit?.e164 ?? "—"}'),
            Text('getPayload(combined): ${_payloadCombined.isEmpty ? "—" : _payloadCombined}'),
            Text('searchCountries("united"): ${_searchResults.map((c) => c.name).join(', ')}'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _controller.setCountry('fr');
                    setState(() {});
                  },
                  child: const Text('setCountry("fr")'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _controller.setValue(
                      const PhoneInputInitialValue(
                        combined: '+1 202 555 0101',
                      ),
                    );
                    setState(() {});
                  },
                  child: const Text('setValue(+1...)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _controller.setTheme(PhoneInputTheme.dark);
                    setState(() {});
                  },
                  child: const Text('setTheme(dark)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _controller.setTheme(PhoneInputTheme.light);
                    setState(() {});
                  },
                  child: const Text('setTheme(light)'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Standalone controller (national mode)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Default country: ${_secondaryController.state.country.name}'),
            Text('Current value: ${_secondaryController.state.formattedValue}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _secondaryController.setCountry('it');
                _secondaryController.setValue(
                  const PhoneInputInitialValue(nationalNumber: '3391234567'),
                );
                setState(() {});
              },
              child: const Text('Switch to Italy + set value'),
            ),
          ],
        ),
      ),
    );
  }
}
