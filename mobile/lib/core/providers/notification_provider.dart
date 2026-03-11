import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final ApiClient _apiClient;
  
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  bool _mounted = true;

  NotificationProvider(this._apiClient);
  
  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotifications() async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _apiClient.get('/notifications');
      
      final dynamic responseData = response.data;
      final List<dynamic> data = responseData is List ? responseData : (responseData['data'] ?? []);
      
      _notifications = data.map((item) => NotificationModel.fromJson(item)).toList();
      _unreadCount = _notifications.where((n) => !n.lu).length;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.error.toString();
    } catch (e) {
      _error = 'Erreur lors du chargement des notifications';
    } finally {
      if (_mounted) _setLoading(false);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.put('/notifications/read-all');
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = NotificationModel(
          id: _notifications[i].id,
          titre: _notifications[i].titre,
          message: _notifications[i].message,
          type: _notifications[i].type,
          lu: true,
          createdAt: _notifications[i].createdAt,
          data: _notifications[i].data,
        );
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      // Ignore error for mark as read
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (_mounted) notifyListeners();
  }
}
