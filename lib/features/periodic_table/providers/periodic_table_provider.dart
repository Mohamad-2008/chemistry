import 'package:flutter/material.dart';
import 'package:periodic_table_app/core/models/element_model.dart';
import 'package:periodic_table_app/features/periodic_table/data/periodic_table_repository.dart';

class PeriodicTableProvider with ChangeNotifier {
  final PeriodicTableRepository _repository = PeriodicTableRepository();
  List<ElementModel> _elements = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<ElementModel> get elements => _elements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPeriodicTableData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _elements = await _repository.loadPeriodicTableData();
      if (_elements.isEmpty) {
        _errorMessage = 'No elements loaded. Check JSON file.';
      } else {
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}