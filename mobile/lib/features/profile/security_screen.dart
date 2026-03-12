import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../auth/pin_login_screen.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _storage = const FlutterSecureStorage();
  final LocalAuthentication _auth = LocalAuthentication();
  bool _biometricsEnabled = false;
  bool _pinExists = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = await _storage.read(key: 'user_pin');
    setState(() {
      _biometricsEnabled = prefs.getBool('biometrics_enabled') ?? false;
      _pinExists = savedPin != null;
    });
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La biométrie est disponible uniquement sur mobile.')),
      );
      return;
    }

    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

    if (!canAuthenticate && value) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Votre appareil ne supporte pas la biométrie.')),
        );
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometrics_enabled', value);
    setState(() => _biometricsEnabled = value);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Biométrie activée' : 'Biométrie désactivée'),
          backgroundColor: const Color(0xFF1B5E20),
        ),
      );
    }
  }

  Future<void> _removePin() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le code PIN ?'),
        content: const Text('La suppression du code PIN diminuera la sécurité de votre compte.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ANNULER'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('SUPPRIMER'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.delete(key: 'user_pin');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometrics_enabled', false);
      setState(() {
        _pinExists = false;
        _biometricsEnabled = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code PIN supprimé'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  void _modifierPin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PinLoginScreen(mode: PinMode.change),
      ),
    ).then((_) => _loadSettings());
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.creamLight,
        appBar: AppBar(
          backgroundColor: const Color(0xFF1B5E20),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Symbols.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Sécurité',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'Code PIN & Biométrie',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    
                    // --- SETTINGS CARD ---
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSecurityTile(
                            icon: Symbols.lock,
                            title: _pinExists ? 'Modifier le code PIN' : 'Configurer un code PIN',
                            subtitle: _pinExists ? 'Activé' : 'Non configuré',
                            onTap: _modifierPin,
                          ),
                          const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                          _buildSecurityTile(
                            icon: Symbols.fingerprint,
                            title: 'Activer la biométrie',
                            subtitle: 'Utilisez Face ID ou votre empreinte',
                            trailing: Switch(
                              value: _biometricsEnabled,
                              onChanged: _toggleBiometrics,
                              activeThumbColor: AppTheme.primaryGold,
                            ),
                          ),
                          const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                          _buildSecurityTile(
                            icon: Symbols.delete_outline,
                            iconColor: Colors.grey.shade400,
                            title: 'Supprimer le code PIN',
                            subtitle: 'Efface vos accès locaux',
                            onTap: _pinExists ? _removePin : null,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // --- INFO CARD ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1B5E20).withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Symbols.info, color: AppTheme.primaryGold, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pour votre sécurité, AURUM vous demandera périodiquement votre code PIN même si la biométrie est activée.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // --- DECORATIVE PATTERN ---
                    Center(
                      child: Opacity(
                        opacity: 0.3,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.withValues(alpha: 0.1),
                          ),
                          child: const CircleAvatar(
                            backgroundColor: AppTheme.primaryGold,
                            child: Text(
                              'A',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 48),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // --- FOOTER BUTTON ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 8,
                      shadowColor: AppTheme.primaryGold.withValues(alpha: 0.2),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Enregistrer les modifications',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Symbols.check, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Version 2.4.0 (AURUM Safe)',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
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

  Widget _buildSecurityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryGold).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor ?? AppTheme.primaryGold, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? const Icon(Symbols.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
