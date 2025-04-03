import 'package:flutter/material.dart';

class ButtonBase extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool? value; // Для кнопки-переключателя
  final IconData? icon; // Иконка перед текстом
  final Color? color; // Цвет кнопки

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
          Text(text),
          if (icon != null) Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
          if (value != null)
            Switch(
              value: value!,
              onChanged: (newValue) => onPressed(),
              inactiveThumbColor: Theme.of(context).colorScheme.secondary,
              thumbColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
              inactiveTrackColor: Theme.of(context).scaffoldBackgroundColor,
              trackColor: MaterialStateProperty.all(Theme.of(context).scaffoldBackgroundColor),
              trackOutlineColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
            ),
        ],
      ),
    );
  }
}