import 'package:flutter/material.dart';

class ScannedValues with ChangeNotifier {
  final List<String> _values = [];

  List<String> get values => _values;

  void addValue(String value) {
    if (!_values.contains(value)) {
      _values.add(value);
      notifyListeners();
    }
  }
}
