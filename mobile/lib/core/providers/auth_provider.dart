import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient _apiClient;
  final _storage = const FlutterSecureStorage();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _mounted = true; // prevent notifying listeners if disposed

  AuthProvider(this._apiClient);
  
  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Mock OTP et Récupération Profil
  Future<void> login(String telephone, String otp) async {
    _setLoading(true);
    _error = null;
    try {
      // 1. Simuler la validation OTP de Firebase
      if (otp != '123456') {
        _error = "Code OTP invalide";
        return;
      }
      
      // 2. Générer un faux token Firebase (JWT) basé sur le numéro
      final mockToken = "mock_firebase_uid_$telephone";
      await _storage.write(key: 'jwt_token', value: mockToken);
      
      // 3. Récupérer le vrai profil PostgreSQL via le backend
      await fetchMe();
      
      if (_user == null) {
        _error = "Utilisateur introuvable. Veuillez vous inscrire.";
        await logout();
      }
    } on DioException catch (e) {
      _error = e.error.toString();
    } catch (e) {
      _error = 'Une erreur inattendue est survenue';
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  // Inscription après "saisie numéro" + OTP (simulé)
  Future<void> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    _error = null;
    try {
      final telephone = userData['telephone'];
      // 1. Simuler Firebase : générer un faux token Firebase
      final mockToken = "mock_firebase_uid_$telephone";
      await _storage.write(key: 'jwt_token', value: mockToken);
      
      // 2. Appeler le backend pour créer l'utilisateur dans PostgreSQL
      final response = await _apiClient.post('/auth/register', data: userData);
      
      if (response.data != null) {
         _user = UserModel.fromJson(response.data);
      }
      notifyListeners();
    } on DioException catch (e) {
      _error = e.error.toString();
      // Si erreur backend, on efface le faux token Firebase
      await _storage.delete(key: 'jwt_token');
    } catch (e) {
      _error = 'Erreur lors de l\'inscription';
      await _storage.delete(key: 'jwt_token');
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  // Mise à jour du profil (MVP)
  Future<void> updateProfile(Map<String, dynamic> userData) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _apiClient.put('/auth/me', data: userData);
      _user = UserModel.fromJson(response.data['user'] ?? response.data);
      notifyListeners();
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? e.message ?? 'Erreur lors de la mise à jour';
    } catch (e) {
      _error = 'Une erreur est survenue lors de la mise à jour';
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  Future<void> fetchMe() async {
    try {
      final response = await _apiClient.get('/auth/me');
      _user = UserModel.fromJson(response.data['user'] ?? response.data);
      notifyListeners();
    } catch (e) {
      await logout();
    }
  }

  // Alias utilisé par ProfileScreen
  Future<void> fetchProfile() async {
    _setLoading(true);
    await fetchMe();
    if (_mounted) _setLoading(false);
  }

  Future<void> tryAutoLogin() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      await fetchMe();
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (_mounted) notifyListeners();
  }
}
