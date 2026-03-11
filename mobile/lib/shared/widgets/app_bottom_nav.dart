import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../features/home/home_screen.dart';
import '../../features/tontines/tontine_list_screen.dart';
import '../../features/activities/wallet_screen.dart';
import '../../features/activities/admin_dashboard_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/home/dashboard_membre_screen.dart';

/// Bottom navigation bar partagée entre tous les écrans.
/// [currentIndex] : 0=Accueil, 1=Tontines, 2=Wallet, 3=Profil
class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        final auth = context.read<AuthProvider>();
        if (auth.user?.roleSysteme == 'admin') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const DashboardMembreScreen()),
            (route) => false,
          );
        }
        break;
      case 1:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TontineListScreen()),
          (route) => false,
        );
        break;
      case 2:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WalletScreen()),
          (route) => false,
        );
        break;
      case 3:
        // Admin → AdminDashboard, sinon Profil
        final auth = context.read<AuthProvider>();
        if (auth.user?.roleSysteme == 'admin') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
            (route) => false,
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white,
      elevation: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(context, 0, Symbols.home, 'ACCUEIL'),
          _item(context, 1, Symbols.pie_chart, 'TONTINES'),
          _item(context, 2, Symbols.account_balance_wallet, 'WALLET'),
          _item(context, 3, Symbols.person, 'PROFIL'),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, int index, IconData icon, String label) {
    final bool selected = index == currentIndex;
    final color = selected ? AppTheme.primaryGold : Colors.grey.shade400;
    return InkWell(
      onTap: () => _navigate(context, index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, fill: selected ? 1 : 0, size: 26),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
