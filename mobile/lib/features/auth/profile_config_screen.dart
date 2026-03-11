import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../home/home_screen.dart';

class ProfileConfigScreen extends StatefulWidget {
  final String phoneNumber;
  const ProfileConfigScreen({super.key, required this.phoneNumber});

  @override
  State<ProfileConfigScreen> createState() => _ProfileConfigScreenState();
}

class _ProfileConfigScreenState extends State<ProfileConfigScreen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phoneNumber;
    // Initialiser avec les données existantes si possible
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nomController.text = user.nom ?? "";
      _prenomController.text = user.prenom ?? "";
      _emailController.text = user.email ?? "";
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final authProvider = context.read<AuthProvider>();
    
    if (_nomController.text.isEmpty || _prenomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir votre nom et prénom')),
      );
      return;
    }

    final userData = {
      'telephone': _phoneController.text.trim(),
      'nom': _nomController.text.trim(),
      'prenom': _prenomController.text.trim(),
      'email': _emailController.text.trim(),
    };

    // Mise à jour du profil via l'API
    await authProvider.updateProfile(userData);

    if (mounted) {
      if (authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error!), backgroundColor: Colors.red),
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppTheme.creamLight,
        appBar: AppBar(
          backgroundColor: AppTheme.creamLight.withValues(alpha: 0.8),
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
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.primaryGold.withValues(alpha: 0.1),
            ),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // --- PHOTO DE PROFIL ---
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.3), width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 64,
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(
                                  user?.photoUrl ?? 
                                  'https://i.pravatar.cc/150?u=${widget.phoneNumber}'
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGold,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.creamLight, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(Symbols.photo_camera, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                          Text(
                            user?.telephone ?? widget.phoneNumber,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1B5E20).withValues(alpha: 0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // --- FORMULAIRE ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('INFORMATIONS PERSONNELLES'),
                          _buildStyledInput(
                            controller: _prenomController,
                            hint: 'Prénom',
                            icon: Symbols.person,
                            iconColor: AppTheme.primaryGold,
                          ),
                          const SizedBox(height: 16),
                          _buildStyledInput(
                            controller: _nomController,
                            hint: 'Nom',
                            icon: Symbols.person,
                            iconColor: AppTheme.primaryGold,
                          ),
                          const SizedBox(height: 16),
                          _buildStyledInput(
                            controller: _emailController,
                            hint: 'Email',
                            icon: Symbols.mail,
                            iconColor: AppTheme.primaryGold,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: 'Numéro de téléphone',
                          controller: _phoneController,
                          hint: '+221 ...',
                          icon: Symbols.call,
                          iconColor: const Color(0xFF22C55E),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: 'Mot de passe',
                          controller: _passwordController,
                          hint: '••••••••',
                          icon: Symbols.lock,
                          iconColor: AppTheme.primaryGold,
                          obscureText: _obscurePassword,
                          trailing: IconButton(
                            icon: Icon(
                              _obscurePassword ? Symbols.visibility : Symbols.visibility_off,
                              color: const Color(0xFF1B5E20).withValues(alpha: 0.4),
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        const SizedBox(height: 120), // Espace pour le bouton fixe
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // --- BOUTON STICKY ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppTheme.creamLight,
                      AppTheme.creamLight.withValues(alpha: 0.9),
                      AppTheme.creamLight.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 8,
                        shadowColor: const Color(0xFF1B5E20).withValues(alpha: 0.3),
                      ),
                      child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Enregistrer les modifications',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              Icon(Symbols.check_circle, size: 20),
                            ],
                          ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildStyledInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
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
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 16, color: AppTheme.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppTheme.textDark.withValues(alpha: 0.3)),
          prefixIcon: Icon(icon, color: iconColor, size: 24),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1B5E20).withValues(alpha: 0.1)),
          boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textDark,
              fontWeight: FontWeight.normal,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: const Color(0xFF1B5E20).withValues(alpha: 0.4)),
              prefixIcon: Icon(icon, color: iconColor, size: 24),
              suffixIcon: trailing,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
