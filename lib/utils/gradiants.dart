// ignore_for_file: non_constant_identifier_names

// utils/gradiants.dart
import 'package:flutter/material.dart';

LinearGradient MeroGradiant() {
  return const LinearGradient(
    colors: [
      Color.fromARGB(255, 34, 34, 34), // Dark grey
      Color.fromARGB(255, 45, 12, 65), // Dark purple
      Color.fromARGB(255, 79, 65, 34), //
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
