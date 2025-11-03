import 'package:flutter/material.dart';

import '../models.dart';
import '../phone_input_controller.dart';

class LbdPhoneInput extends StatefulWidget {
  const LbdPhoneInput({
    super.key,
    this.controller,
    this.options = const PhoneInputOptions(),
    this.onChanged,
    this.focusNode,
    this.decoration,
    this.style,
    this.enabled = true,
    this.textInputAction,
    this.keyboardAppearance,
    this.selectorPadding = const EdgeInsets.symmetric(horizontal: 12),
  });

  final LbdPhoneInputController? controller;
  final PhoneInputOptions options;
  final ValueChanged<PhoneInputState>? onChanged;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextStyle? style;
  final bool enabled;
  final TextInputAction? textInputAction;
  final Brightness? keyboardAppearance;
  final EdgeInsets selectorPadding;

  @override
  State<LbdPhoneInput> createState() => _LbdPhoneInputState();
}

class _LbdPhoneInputState extends State<LbdPhoneInput> {
  late LbdPhoneInputController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(covariant LbdPhoneInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _detachController();
      _initializeController();
    } else if (widget.options != oldWidget.options) {
      _controller.updateOptions(widget.options);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.applyBrightness(Theme.of(context).brightness);
  }

  @override
  void dispose() {
    _detachController();
    super.dispose();
  }

  void _initializeController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
      _controller.updateOptions(widget.options);
    } else {
      _controller = LbdPhoneInputController(options: widget.options);
      _ownsController = true;
    }
    _controller.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onChanged?.call(_controller.state);
      }
    });
  }

  void _detachController() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    _ownsController = false;
  }

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
    widget.onChanged?.call(_controller.state);
  }

  @override
  Widget build(BuildContext context) {
    final translations = _controller.translations;
    final theme = Theme.of(context);
    _controller.applyBrightness(theme.brightness);

    final placeholder = _controller.placeholder;
    final decoration = (widget.decoration ?? const InputDecoration()).copyWith(
      hintText: widget.decoration?.hintText ?? placeholder,
    );

    return Semantics(
      container: true,
      child: Row(
        children: [
          _CountrySelectorButton(
            controller: _controller,
            padding: widget.selectorPadding,
            enabled: widget.enabled,
            semanticsLabel: translations.ariaLabelSelector,
            onSelected: (country) {
              _controller.setCountry(country.iso2);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller.textController,
              focusNode: widget.focusNode,
              enabled: widget.enabled,
              keyboardType: TextInputType.phone,
              textInputAction: widget.textInputAction,
              keyboardAppearance:
                  widget.keyboardAppearance ?? theme.brightness,
              decoration: decoration,
              style: widget.style,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountrySelectorButton extends StatelessWidget {
  const _CountrySelectorButton({
    required this.controller,
    required this.padding,
    required this.enabled,
    required this.semanticsLabel,
    this.onSelected,
  });

  final LbdPhoneInputController controller;
  final EdgeInsets padding;
  final bool enabled;
  final String semanticsLabel;
  final ValueChanged<Country>? onSelected;

  @override
  Widget build(BuildContext context) {
    final country = controller.country;
    final flagMode = controller.options.flagDisplay;
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: InkWell(
        onTap: enabled ? () => _openPicker(context) : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (flagMode != FlagDisplayMode.none)
                Text(
                  country.flag,
                  style: const TextStyle(fontSize: 20),
                ),
              if (flagMode != FlagDisplayMode.none) const SizedBox(width: 6),
              Text(
                country.dialCode,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final result = await showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CountryPickerSheet(controller: controller),
    );
    if (result != null) {
      onSelected?.call(result);
    }
  }
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({required this.controller});

  final LbdPhoneInputController controller;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  late TextEditingController _searchController;
  late List<Country> _filtered;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filtered = widget.controller.countries;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _filtered = widget.controller.searchCountries(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final translations = widget.controller.translations;
    final maxHeight = MediaQuery.of(context).size.height * 0.75;
    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: translations.searchPlaceholder,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(child: Text(translations.noResults))
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final country = _filtered[index];
                        final isActive =
                            country.iso2 == widget.controller.country.iso2;
                        return ListTile(
                          leading: widget.controller.options.flagDisplay ==
                                  FlagDisplayMode.none
                              ? null
                              : Text(
                                  country.flag,
                                  style: const TextStyle(fontSize: 24),
                                ),
                          title: Text(country.name),
                          subtitle: Text(country.dialCode),
                          trailing:
                              isActive ? const Icon(Icons.check) : null,
                          onTap: () {
                            widget.controller.setCountry(country.iso2);
                            if (widget.controller.options
                                .closeDropdownOnSelection) {
                              Navigator.of(context).pop(country);
                            } else {
                              setState(() {});
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
