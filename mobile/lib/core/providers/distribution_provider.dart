import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/distribution_model.dart';

class DistributionProvider with ChangeNotifier {
  final ApiClient _apiClient;
  
  List<DistributionModel> _distributions = [];
  bool _isLoading = false;
  String? _error;
  bool _mounted = true;

  DistributionProvider(this._apiClient);

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  List<DistributionModel> get distributions => _distributions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> triggerDistribution(Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;
    try {
      await _apiClient.post('/distributions', data: data);
      notifyListeners();
    } on DioException catch (e) {
      _error = e.error.toString();
    } catch (e) {
      _error = 'Erreur lors du déclenchement de la distribution';
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  Future<void> fetchCycleDistributions(String cycleId) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _apiClient.get('/distributions/cycle/$cycleId');
      final List<dynamic> data = response.data['data'] ?? response.data;
      _distributions = data.map((item) => DistributionModel.fromJson(item)).toList();
      notifyListeners();
    } on DioException catch (e) {
      _error = e.error.toString();
    } catch (e) {
      _error = 'Erreur lors du chargement des distributions';
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (_mounted) notifyListeners();
  }
}
