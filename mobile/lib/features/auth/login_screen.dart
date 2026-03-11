import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../theme/app_theme.dart';
import 'package:flutter/services.dart';
import '../auth/register_screen.dart';
import '../home/home_screen.dart';

import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final authProvider = context.read<AuthProvider>();
    final phone = '+226${_phoneController.text.trim().replaceAll(' ', '')}';
    final password = _passwordController.text;

    if (phone.length < 10 || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    await authProvider.login(phone, password);

    if (mounted) {
      if (authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error!), backgroundColor: Colors.red),
        );
      } else if (authProvider.isAuthenticated) {
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
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        body: Stack(
          children: [
            // Motif de fond subtil
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(
                  painter: GridPatternPainter(),
                ),
              ),
            ),
            
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Symbols.arrow_back, color: AppTheme.primaryGold),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                                  padding: const EdgeInsets.all(12),
                                ),
                              ),
                              const Text(
                                'Connexion',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 48), // Spacer
                            ],
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Hero Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Symbols.account_balance_wallet,
                              color: AppTheme.primaryGold,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Bienvenue sur AURUM',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Accédez à votre compte exclusif et gérez vos actifs avec sérénité.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.grayText,
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Login Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 30,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Phone Number
                                const Text(
                                  'NUMÉRO DE TÉLÉPHONE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    color: AppTheme.grayText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      height: 56,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.creamLight.withValues(alpha: 0.3),
                                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                                        border: Border.all(color: const Color(0xFFE5E3DC)),
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(2),
                                            child: Image.network(
                                              'https://flagcdn.com/w40/bf.png',
                                              width: 24,
                                              height: 16,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            '+226',
                                            style: TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(width: 1, height: 24, color: const Color(0xFFE5E3DC)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        maxLength: 11, // 8 chiffres + 3 espaces
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          _PhoneInputFormatter(),
                                        ],
                                        decoration: InputDecoration(
                                          hintText: '00 00 00 00',
                                          fillColor: AppTheme.creamLight.withValues(alpha: 0.3),
                                          counterText: '',
                                          border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                                            borderSide: BorderSide(color: Color(0xFFE5E3DC)),
                                          ),
                                          enabledBorder: const OutlineInputBorder(
                                            borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                                            borderSide: BorderSide(color: Color(0xFFE5E3DC)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Password
                                const Text(
                                  'MOT DE PASSE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    color: AppTheme.grayText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    fillColor: AppTheme.creamLight.withValues(alpha: 0.3),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible ? Symbols.visibility_off : Symbols.visibility,
                                        color: AppTheme.grayText,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Mot de passe oublié ?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryGold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Login Button
                                Consumer<AuthProvider>(
                                  builder: (context, auth, _) {
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: auth.isLoading ? null : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryGold,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                          elevation: 8,
                                          shadowColor: AppTheme.primaryGold.withValues(alpha: 0.4),
                                        ),
                                        child: auth.isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : const Text('Se connecter'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Social Login
                          Row(
                            children: [
                              Expanded(child: Container(height: 1, color: const Color(0xFFE5E3DC))),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  'OU CONTINUER AVEC',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    color: AppTheme.grayText,
                                  ),
                                ),
                              ),
                              Expanded(child: Container(height: 1, color: const Color(0xFFE5E3DC))),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Image.network(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 32),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: const Icon(Icons.apple, color: Colors.white, size: 32),
                                ),
                              ),
                            ],
                          ),
                          
                          const Spacer(),
                          
                          // Footer
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Pas encore de compte ?',
                                  style: TextStyle(color: AppTheme.grayText),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                    );
                                  },
                                  child: const Text(
                                    'Créer un compte',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryGold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
}

// Peintre pour le motif de grille
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryGold
      ..strokeWidth = 1;

    const double spacing = 24;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    if (newText.length > oldValue.text.length) {
      if (newText.replaceAll(' ', '').length > 8) return oldValue;
      
      final buffer = StringBuffer();
      int i = 0;
      for (int j = 0; j < newText.length; j++) {
        if (newText[j] != ' ') {
          buffer.write(newText[j]);
          i++;
          if (i % 2 == 0 && i != 8 && j != newText.length - 1) {
            buffer.write(' ');
          }
        }
      }
      
      final string = buffer.toString();
      return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length),
      );
    }
    return newValue;
  }
}
