import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final ApiClient _apiClient;
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  NotificationProvider(this._apiClient);

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.lu).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/notifications');
      final List<dynamic> data = response.data['notifications'] ?? response.data;
      _notifications = data.map((n) => NotificationModel.fromJson(n)).toList();
      
      // Sort by date (most recent first)
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = 'Impossible de charger les notifications';
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.put('/notifications/$id/lue');
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final n = _notifications[index];
        _notifications[index] = NotificationModel(
          id: n.id,
          titre: n.titre,
          message: n.message,
          type: n.type,
          lu: true,
          createdAt: n.createdAt,
          data: n.data,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.put('/notifications/toutes/lues');
      for (int i = 0; i < _notifications.length; i++) {
        final n = _notifications[i];
        _notifications[i] = NotificationModel(
          id: n.id,
          titre: n.titre,
          message: n.message,
          type: n.type,
          lu: true,
          createdAt: n.createdAt,
          data: n.data,
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }
}
