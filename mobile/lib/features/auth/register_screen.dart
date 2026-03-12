import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/features/auth/profile_config_screen.dart';
import 'package:mobile_app/features/auth/login_screen.dart';
import '../../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());

  @override
  void dispose() {
    _phoneController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _nextField(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _handleVerify() async {
    final phone = '+226${_phoneController.text.trim().replaceAll(' ', '')}';
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un numéro valide')),
      );
      return;
    }

    // Récupération de l'OTP
    final otp = _controllers.map((c) => c.text).join();
    if (otp != '123456') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code OTP invalide (utilisez 123456 pour simuler)'), backgroundColor: Colors.orange),
      );
      return;
    }

    // Navigation vers la configuration du profil au lieu de l'inscription directe
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileConfigScreen(phoneNumber: phone),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // TopAppBar
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Symbols.arrow_back, color: AppTheme.textDark),
                            style: IconButton.styleFrom(
                              hoverColor: Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 48.0),
                                child: const Text(
                                  'Créer un compte',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Central Card
                      Container(
                        padding: const EdgeInsets.all(32),
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
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bienvenue',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Entrez votre numéro pour commencer l'expérience AURUM.",
                              style: TextStyle(color: AppTheme.grayText, fontSize: 16),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Invitation Code
                            const Text(
                              'Code d\'invitation (Optionnel)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Entrez votre code',
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE5E3DC)),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Phone Number
                            const Text(
                              'Numéro de téléphone',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  height: 56,
                                  width: 80,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE5E3DC)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    '+226',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 11, // 8 digits + 3 spaces
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        _PhoneInputFormatter(),
                                      ],
                                      decoration: const InputDecoration(
                                        hintText: '00 00 00 00',
                                        fillColor: Colors.white,
                                        counterText: '',
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // OTP Section
                            const Text(
                              'Code de vérification',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                return SizedBox(
                                  width: 45,
                                  height: 50,
                                  child: TextField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    onChanged: (value) => _nextField(value, index),
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryGold,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.zero,
                                      fillColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFE5E3DC)),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            
                            const SizedBox(height: 16),
                            Center(
                              child: Text.rich(
                                TextSpan(
                                  text: 'Vous n\'avez pas reçu le code ? ',
                                  style: const TextStyle(color: AppTheme.grayText, fontSize: 13),
                                  children: [
                                    const TextSpan(
                                      text: 'Renvoyer dans 00:59',
                                      style: TextStyle(
                                        color: AppTheme.primaryGold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Verify Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _handleVerify,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGold,
                                  foregroundColor: AppTheme.textDark,
                                  elevation: 8,
                                  shadowColor: AppTheme.primaryGold.withValues(alpha: 0.2),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Continuer'),
                                    SizedBox(width: 8),
                                    Icon(Symbols.chevron_right),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Déjà un compte ?',
                            style: TextStyle(color: AppTheme.grayText),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: const Text(
                              'Se connecter',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Social Options
                      Row(
                        children: [
                          Expanded(child: Container(height: 1, color: AppTheme.grayText.withValues(alpha: 0.2))),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'OU CONTINUER AVEC',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.grayText,
                              ),
                            ),
                          ),
                          Expanded(child: Container(height: 1, color: AppTheme.grayText.withValues(alpha: 0.2))),
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
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Column(
                          children: [
                            const Text(
                              'En continuant, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.grayText, fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.primaryGold, shape: BoxShape.circle)),
                                const SizedBox(width: 16),
                                Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.primaryGold, shape: BoxShape.circle)),
                                const SizedBox(width: 16),
                                Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.primaryGold, shape: BoxShape.circle)),
                              ],
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
      ),
    );
  }
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
