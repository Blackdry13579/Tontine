import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.creamLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Symbols.arrow_back, color: AppTheme.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Mes Notifications',
            style: TextStyle(
              color: AppTheme.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Symbols.done_all, color: Color(0xFF1B5E20)),
              onPressed: () => context.read<NotificationProvider>().markAllAsRead(),
              tooltip: 'Tout marquer comme lu',
            ),
          ],
        ),
        body: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.notifications.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)));
            }

            if (provider.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Icon(Symbols.notifications_off, size: 80, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Aucune notification',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toutes vos alertes s\'afficheront ici.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: provider.fetchNotifications,
              color: const Color(0xFF1B5E20),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notification = provider.notifications[index];
                  return _buildNotificationItem(context, provider, notification);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationProvider provider, NotificationModel notification) {
    final dateFormat = DateFormat('dd MMM, HH:mm');
    
    return InkWell(
      onTap: () {
        if (!notification.lu) {
          provider.markAsRead(notification.id);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.lu ? Colors.white : const Color(0xFF1B5E20).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.lu ? Colors.grey.withValues(alpha: 0.1) : const Color(0xFF1B5E20).withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.titre,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notification.lu ? FontWeight.w600 : FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      if (!notification.lu)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1B5E20),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: notification.lu ? Colors.grey[600] : AppTheme.textDark.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dateFormat.format(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'payment': return Symbols.payments;
      case 'tontine': return Symbols.group;
      case 'alert': return Symbols.warning;
      case 'win': return Symbols.celebration;
      default: return Symbols.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'payment': return Colors.blue;
      case 'tontine': return AppTheme.primaryGold;
      case 'alert': return Colors.red;
      case 'win': return const Color(0xFF1B5E20);
      default: return Colors.orange;
    }
  }
}
