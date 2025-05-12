import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

class SearchPoly extends StatefulWidget {
  Function(String) onChanged;
  SearchPoly({super.key, required this.onChanged});

  @override
  State<SearchPoly> createState() => _SearchPolyState();
}

class _SearchPolyState extends State<SearchPoly> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: TextField(
        onChanged: widget.onChanged,
        cursorColor: Theme.of(context).colorScheme.surface,
        style:
        TextStyle(color: Theme.of(context).colorScheme.secondary),
        decoration: InputDecoration(
            isDense: true,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            filled: true,
            fillColor: Theme.of(context)
                .scaffoldBackgroundColor
                .withAlpha(180),
            hintText: S.of(context).search,
            hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    width: 3,
                    color: Theme.of(context).colorScheme.secondary)),
            prefixIcon: const Icon(Icons.search),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  width: 1.5,
                  color: Theme.of(context).colorScheme.secondary),
            )),
      ),
    );
  }
}
