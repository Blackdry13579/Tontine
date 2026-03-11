import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/tontine_model.dart';

class TontineProvider with ChangeNotifier {
  final ApiClient _apiClient;
  
  List<TontineModel> _tontines = [];
  TontineModel? _currentTontine;
  bool _isLoading = false;
  String? _error;
  bool _mounted = true;

  TontineProvider(this._apiClient);
  
  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  List<TontineModel> get tontines => _tontines;
  TontineModel? get currentTontine => _currentTontine;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTontines() async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _apiClient.get('/tontines');
      
      final dynamic responseData = response.data;
      final List<dynamic> data = responseData is List ? responseData : (responseData['data'] ?? []);
      
      _tontines = data.map((item) => TontineModel.fromJson(item)).toList();
      notifyListeners();
    } on DioException catch (e) {
      _error = e.error.toString();
    } catch (e) {
      _error = 'Erreur lors du chargement des tontines: $e';
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  Future<void> fetchTontineById(String id) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _apiClient.get('/tontines/$id');
      _currentTontine = TontineModel.fromJson(response.data['data'] ?? response.data);
      notifyListeners();
    } on DioException catch (e) {
      _error = e.error.toString();
    } catch (e) {
      _error = 'Erreur lors du chargement de la tontine: $e';
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  Future<void> createTontine(TontineModel tontine) async {
    _setLoading(true);
    _error = null;
    try {
      await _apiClient.post('/tontines', data: tontine.toJson());
      await fetchTontines(); // Refresh list
    } on DioException catch (e) {
      _error = e.error.toString();
    } catch (e) {
      _error = 'Erreur lors de la création de la tontine';
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  Future<void> joinTontine(String code) async {
    _setLoading(true);
    _error = null;
    try {
      await _apiClient.post('/memberships/join', data: {'code': code});
      await fetchTontines(); // Refresh list
    } on DioException catch (e) {
      _error = e.error.toString();
    } catch (e) {
      _error = 'Erreur lors de l\'adhésion à la tontine';
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  Future<void> updateTontine(String id, Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;
    try {
      await _apiClient.put('/tontines/$id', data: data);
      await fetchTontineById(id); // Refresh current
    } on DioException catch (e) {
      _error = e.error.toString();
    } catch (e) {
      _error = 'Erreur lors de la mise à jour de la tontine';
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  Future<void> updateMembershipOrder(String tontineId, List<Map<String, dynamic>> orders) async {
    _setLoading(true);
    _error = null;
    try {
      await _apiClient.put('/memberships/tontine/$tontineId/ordre', data: {'orders': orders});
      // Assuming fetchMembers is the correct method to refresh members
      await fetchMembers(tontineId); // Refresh members to get new order
    } on DioException catch (e) {
      _error = e.error.toString();
    } catch (e) {
      _error = 'Erreur lors de la mise à jour de l\'ordre';
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  Future<void> updateTontineStatus(String id, String status) async {
    _setLoading(true);
    _error = null;
    try {
      await _apiClient.patch('/tontines/$id/statut', data: {'statut': status});
      await fetchTontineById(id); // Refresh current
    } on DioException catch (e) {
      _error = e.error.toString();
    } catch (e) {
      _error = 'Erreur lors du changement de statut de la tontine';
    } finally {
      if (_mounted) _setLoading(false);
    }
  }
  List<dynamic> _members = [];
  List<dynamic> get members => _members;

  Future<void> fetchMembers(String tontineId) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _apiClient.get('/memberships/tontine/$tontineId');
      _members = response.data['data'] ?? response.data;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.error.toString();
    } catch (e) {
      _error = 'Erreur lors du chargement des membres';
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> fetchAdminDashboard() async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _apiClient.get('/admin/dashboard');
      return response.data['data'] ?? response.data;
    } on DioException catch (e) {
      _error = e.error.toString();
      return null;
    } catch (e) {
      _error = 'Erreur lors du chargement du dashboard admin';
      return null;
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  Future<List<dynamic>> fetchTontineAudit(String tontineId) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _apiClient.get('/admin/tontine/$tontineId/journal');
      return response.data['data'] ?? response.data;
    } on DioException catch (e) {
      _error = e.error.toString();
      return [];
    } catch (e) {
      _error = 'Erreur lors du chargement du journal d\'audit';
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
