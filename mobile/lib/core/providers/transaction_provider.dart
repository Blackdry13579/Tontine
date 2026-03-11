import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  final ApiClient _apiClient;
  
  List<TransactionModel> _history = [];
  Map<String, dynamic>? _resume;
  bool _isLoading = false;
  String? _error;
  bool _mounted = true;

  TransactionProvider(this._apiClient);

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  List<TransactionModel> get history => _history;
  Map<String, dynamic>? get resume => _resume;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchHistory() async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _apiClient.get('/wallet');
      final dynamic responseData = response.data;
      
      _resume = responseData['resume'];
      final List<dynamic> historyData = responseData['historique'] ?? [];
      _history = historyData.map((item) => TransactionModel.fromJson(item)).toList();
      notifyListeners();
    } on DioException catch (e) {
      _error = e.error.toString();
    } catch (e) {
      _error = 'Erreur lors du chargement de l\'historique: $e';
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  Future<void> submitCotisation(Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;
    try {
      await _apiClient.post('/cotisations/soumettre', data: data);
    } on DioException catch (e) {
      _error = e.error.toString();
    } catch (e) {
      _error = 'Erreur lors de la soumission de la cotisation';
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  Future<List<dynamic>> fetchCycleCotisations(String cycleId) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _apiClient.get('/cotisations/cycle/$cycleId');
      return response.data;
    } on DioException catch (e) {
      _error = e.error.toString();
      return [];
    } catch (e) {
      _error = 'Erreur lors du chargement des cotisations du cycle';
      return [];
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  Future<void> validateCotisation(String cotisationId) async {
    _setLoading(true);
    _error = null;
    try {
      await _apiClient.post('/cotisations/$cotisationId/valider');
    } on DioException catch (e) {
      _error = e.error.toString();
    } catch (e) {
      _error = 'Erreur lors de la validation';
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  Future<void> rejectCotisation(String cotisationId, String motif) async {
    _setLoading(true);
    _error = null;
    try {
      await _apiClient.post('/cotisations/$cotisationId/rejeter', data: {'motif': motif});
    } on DioException catch (e) {
      _error = e.error.toString();
    } catch (e) {
      _error = 'Erreur lors du rejet';
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  Future<List<dynamic>> fetchPendingValidations() async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _apiClient.get('/cotisations/en-attente-validation');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      _error = e.error.toString();
      return [];
    } catch (e) {
      _error = 'Erreur lors du chargement des validations en attente';
      return [];
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (_mounted) notifyListeners();
  }
}
