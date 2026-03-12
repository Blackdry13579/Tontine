import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../auth/profile_config_screen.dart';
import '../welcome/welcome_screen.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import 'security_screen.dart';
import 'help_center_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchProfile();
    });
  }

  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Notifications activées' : 'Notifications désactivées'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleLogout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.creamLight,
        appBar: AppBar(
          backgroundColor: AppTheme.creamLight,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Symbols.arrow_back, color: Color(0xFF1B5E20)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'MON PROFIL',
            style: TextStyle(
              color: Color(0xFF1B5E20),
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final user = auth.user;
            
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // --- PROFILE HEADER ---
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primaryGold, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryGold.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                                child: CircleAvatar(
                                  radius: 68,
                                  backgroundColor: AppTheme.primaryGold,
                                  child: Text(
                                    user?.prenom?.isNotEmpty == true ? user!.prenom![0].toUpperCase() : 'U', 
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 48),
                                  ),
                                ),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  if (user?.telephone != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProfileConfigScreen(phoneNumber: user!.telephone),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B5E20),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.creamLight, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Symbols.edit, color: AppTheme.primaryGold, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${user?.prenom ?? "Chargement..."} ${user?.nom ?? ""}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.telephone ?? "+--- -- -- -- --",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1B5E20).withValues(alpha: 0.7),
                          ),
                        ),
                        if (user?.email != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            user!.email!,
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF1B5E20).withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // --- SECTIONS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('PROFIL & PRÉFÉRENCES'),
                        _buildSettingsGroup([
                          _buildSettingTile(
                            icon: Symbols.person_edit,
                            iconColor: Colors.blue.shade900,
                            label: 'Modifier profil',
                            onTap: () {
                              if (user?.telephone != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProfileConfigScreen(phoneNumber: user!.telephone),
                                  ),
                                );
                              }
                            },
                          ),
                        ]),
                        
                        const SizedBox(height: 24),
                        _buildSectionHeader('SÉCURITÉ ET ACCÈS'),
                        _buildSettingsGroup([
                          _buildSettingTile(
                            icon: Symbols.lock,
                            iconColor: Colors.teal.shade700,
                            label: 'Sécurité',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SecurityScreen()),
                              );
                            },
                          ),
                        ]),
                        
                        const SizedBox(height: 24),
                        _buildSectionHeader('GÉNÉRAL'),
                        _buildSettingsGroup([
                          _buildSettingTile(
                            icon: Symbols.notifications,
                            iconColor: Colors.orange.shade600,
                            label: 'Notifications',
                            trailing: Switch(
                              value: _notificationsEnabled,
                              onChanged: _toggleNotifications,
                              activeThumbColor: const Color(0xFF1B5E20),
                            ),
                          ),
                          _buildDivider(),
                          _buildSettingTile(
                            icon: Symbols.help,
                            iconColor: Colors.orange.shade600,
                            label: 'Centre d\'aide',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
                              );
                            },
                          ),
                        ]),
                        
                        const SizedBox(height: 24),
                        _buildSectionHeader('GESTION DU COMPTE'),
                        _buildSettingsGroup([
                          _buildSettingTile(
                            icon: Symbols.logout,
                            iconColor: Colors.red.shade600,
                            label: 'Se déconnecter',
                            textColor: Colors.red.shade600,
                            onTap: _handleLogout,
                          ),
                        ]),
                        
                        const SizedBox(height: 100), // Height for bottom nav
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1B5E20).withValues(alpha: 0.4),
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? AppTheme.textDark,
                ),
              ),
            ),
            trailing ?? Icon(Symbols.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: AppTheme.primaryGold.withValues(alpha: 0.1),
      ),
    );
  }
}
