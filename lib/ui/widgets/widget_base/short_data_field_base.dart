import 'package:flutter/material.dart';

class ShortDataField extends StatelessWidget {
  final String label;
  final String value;
  final bool readOnly;

  const ShortDataField({super.key, required this.label, required this.value, required this.readOnly});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextField(
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          contentPadding: EdgeInsets.zero,
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 20),
          border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface, width: 2)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.surface, width: 1)),
        ),
        controller: TextEditingController(text: value),
      ),
    );
  }
}