import 'package:flutter/material.dart';

class BanakoTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;

  const BanakoTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<BanakoTextField> createState() => _BanakoTextFieldState();
}

class _BanakoTextFieldState extends State<BanakoTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      constraints: const BoxConstraints(minHeight: 50, minWidth: 1200),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      ),
    );
  }
}
