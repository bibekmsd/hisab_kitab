import 'package:flutter/material.dart';

class RadioTextWidget extends StatelessWidget {
  final String text;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const RadioTextWidget({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Radio<bool>(
          value: true,
          groupValue: isSelected ? true : null,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
