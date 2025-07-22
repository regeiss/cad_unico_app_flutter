// lib/widgets/search_bar_widget.dart
import 'dart:async';

import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final String? hintText;
  final Function(String)? onSearch;
  final Function(String)? onChanged;
  final VoidCallback? onClear;
  final String? initialValue;
  final bool enabled;
  final Duration debounceTime;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;

  const SearchBarWidget({
    super.key,
    this.hintText = 'Pesquisar...',
    this.onSearch,
    this.onChanged,
    this.onClear,
    this.initialValue,
    this.enabled = true,
    this.debounceTime = const Duration(milliseconds: 500),
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  Timer? _debounceTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _hasText = widget.initialValue?.isNotEmpty ?? false;

    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });

      // Cancelar timer anterior se existir
      _debounceTimer?.cancel();

      // Criar novo timer para debounce
      _debounceTimer = Timer(widget.debounceTime, () {
        if (widget.onChanged != null) {
          widget.onChanged!(_controller.text);
        }
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onClear() {
    _controller.clear();
    if (widget.onClear != null) {
      widget.onClear!();
    }
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

  void _onSubmitted(String value) {
    if (widget.onSearch != null) {
      widget.onSearch!(value);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: (0.05)),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        onSubmitted: _onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: widget.prefixIcon ??
              Icon(
                Icons.search,
                color: Colors.grey[600],
                size: 22,
              ),
          suffixIcon: _buildSuffixIcon(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          filled: true,
          fillColor:
              widget.enabled ? Theme.of(context).cardColor : Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    if (!_hasText) {
      return null;
    }

    return IconButton(
      icon: Icon(
        Icons.clear,
        color: Colors.grey[600],
        size: 20,
      ),
      onPressed: widget.enabled ? _onClear : null,
      tooltip: 'Limpar pesquisa',
    );
  }
}

// Widget de pesquisa com filtros
class SearchBarWithFilters extends StatefulWidget {
  final String? hintText;
  final Function(String)? onSearch;
  final Function(String)? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final String? initialValue;
  final bool enabled;
  final bool hasActiveFilters;
  final int? filterCount;

  const SearchBarWithFilters({
    super.key,
    this.hintText = 'Pesquisar...',
    this.onSearch,
    this.onChanged,
    this.onClear,
    this.onFilterTap,
    this.initialValue,
    this.enabled = true,
    this.hasActiveFilters = false,
    this.filterCount,
  });

  @override
  State<SearchBarWithFilters> createState() => _SearchBarWithFiltersState();
}

class _SearchBarWithFiltersState extends State<SearchBarWithFilters> {
  @override
  Widget build(BuildContext context) => Row(
      children: [
        Expanded(
          child: SearchBarWidget(
            hintText: widget.hintText,
            onSearch: widget.onSearch,
            onChanged: widget.onChanged,
            onClear: widget.onClear,
            initialValue: widget.initialValue,
            enabled: widget.enabled,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: widget.hasActiveFilters
                ? Theme.of(context).primaryColor
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.hasActiveFilters
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: widget.enabled ? widget.onFilterTap : null,
            icon: Stack(
              children: [
                Icon(
                  Icons.filter_list,
                  color:
                      widget.hasActiveFilters ? Colors.white : Colors.grey[600],
                  size: 22,
                ),
                if (widget.hasActiveFilters && widget.filterCount != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        widget.filterCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Filtros',
          ),
        ),
      ],
    );
}

// Widget de pesquisa compacta para mobile
class CompactSearchBar extends StatefulWidget {
  final String? hintText;
  final Function(String)? onSearch;
  final Function(String)? onChanged;
  final VoidCallback? onClear;
  final String? initialValue;
  final bool enabled;

  const CompactSearchBar({
    super.key,
    this.hintText = 'Pesquisar...',
    this.onSearch,
    this.onChanged,
    this.onClear,
    this.initialValue,
    this.enabled = true,
  });

  @override
  State<CompactSearchBar> createState() => _CompactSearchBarState();
}

class _CompactSearchBarState extends State<CompactSearchBar> {
  late TextEditingController _controller;
  bool _isExpanded = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _isExpanded = widget.initialValue?.isNotEmpty ?? false;

    _controller.addListener(() {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (widget.onChanged != null) {
          widget.onChanged!(_controller.text);
        }
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (!_isExpanded) {
        _controller.clear();
        if (widget.onClear != null) {
          widget.onClear!();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _isExpanded ? double.infinity : 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              _isExpanded ? Theme.of(context).primaryColor : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.enabled ? _toggleSearch : null,
            icon: Icon(
              _isExpanded ? Icons.arrow_back : Icons.search,
              color: _isExpanded
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
          ),
          if (_isExpanded)
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                autofocus: true,
                onSubmitted: (value) {
                  if (widget.onSearch != null) {
                    widget.onSearch!(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          if (_isExpanded && _controller.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _controller.clear();
                if (widget.onClear != null) {
                  widget.onClear!();
                }
              },
              icon: Icon(
                Icons.clear,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
        ],
      ),
    );
}

// Widget de pesquisa com sugestões
class SearchBarWithSuggestions extends StatefulWidget {
  final String? hintText;
  final Function(String)? onSearch;
  final Function(String)? onChanged;
  final Function(String)? onSuggestionTap;
  final Future<List<String>> Function(String)? onGetSuggestions;
  final String? initialValue;
  final bool enabled;
  final int maxSuggestions;

  const SearchBarWithSuggestions({
    super.key,
    this.hintText = 'Pesquisar...',
    this.onSearch,
    this.onChanged,
    this.onSuggestionTap,
    this.onGetSuggestions,
    this.initialValue,
    this.enabled = true,
    this.maxSuggestions = 5,
  });

  @override
  State<SearchBarWithSuggestions> createState() =>
      _SearchBarWithSuggestionsState();
}

class _SearchBarWithSuggestionsState extends State<SearchBarWithSuggestions> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = [];
  bool _showSuggestions = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _getSuggestions(_controller.text);
      if (widget.onChanged != null) {
        widget.onChanged!(_controller.text);
      }
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _controller.text.isNotEmpty) {
      _getSuggestions(_controller.text);
    } else {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  Future<void> _getSuggestions(String query) async {
    if (query.isEmpty || widget.onGetSuggestions == null) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    try {
      final suggestions = await widget.onGetSuggestions!(query);
      setState(() {
        _suggestions = suggestions.take(widget.maxSuggestions).toList();
        _showSuggestions = _suggestions.isNotEmpty && _focusNode.hasFocus;
      });
    } on Exception  {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }

  void _onSuggestionSelected(String suggestion) {
    _controller.text = suggestion;
    setState(() {
      _showSuggestions = false;
    });
    _focusNode.unfocus();

    if (widget.onSuggestionTap != null) {
      widget.onSuggestionTap!(suggestion);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
      children: [
        SearchBarWidget(
          hintText: widget.hintText,
          onSearch: widget.onSearch,
          initialValue: widget.initialValue,
          enabled: widget.enabled,
          onChanged: (value) {}, // Handled by controller listener
        ),
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: (0.1)),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  title: Text(
                    suggestion,
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () => _onSuggestionSelected(suggestion),
                );
              },
            ),
          ),
      ],
    );
}
