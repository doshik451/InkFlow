import 'package:flutter/material.dart';

class ButtonBase extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool? value;
  final IconData? icon;
  final Color? color;

  const ButtonBase({
    super.key,
    required this.text,
    required this.onPressed,
    this.value,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        foregroundColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1),
        ),
        textStyle: const TextStyle(fontSize: 16, fontFamily: 'YanoneKaffeesatz'),
        alignment: Alignment.centerLeft,
        minimumSize: const Size(350, 50),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(text, softWrap: true,),
          )),
          if (icon != null) Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
          if (value != null)
            Switch(
              value: value!,
              onChanged: (newValue) => onPressed(),
              padding: EdgeInsets.zero,
              inactiveThumbColor: Theme.of(context).colorScheme.secondary,
              thumbColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary),
              inactiveTrackColor: Theme.of(context).scaffoldBackgroundColor,
              trackColor: WidgetStateProperty.all(Theme.of(context).scaffoldBackgroundColor),
              trackOutlineColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary),
            ),
        ],
      ),
    );
  }
}