import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../theme/app_theme.dart';
import '../home/home_screen.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  String _pin = '';
  final int _pinLength = 6;

  void _onNumberPressed(String number) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += number;
      });
      if (_pin.length == _pinLength) {
        // Simulation de validation
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        });
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Header
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Symbols.security, color: AppTheme.primaryGold, size: 48, fill: 1),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Bienvenue',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Saisissez votre code PIN',
                    style: TextStyle(fontSize: 16, color: AppTheme.grayText, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // PIN Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (index) {
                  bool isFilled = index < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? AppTheme.primaryGold : Colors.transparent,
                      border: Border.all(
                        color: AppTheme.primaryGold.withValues(alpha: isFilled ? 1 : 0.3),
                        width: 2,
                      ),
                      boxShadow: isFilled ? [BoxShadow(color: AppTheme.primaryGold.withValues(alpha: 0.4), blurRadius: 10)] : null,
                    ),
                  );
                }),
              ),
              
              const Spacer(),
              
              // Numpad
              _buildNumpad(),
              
              const SizedBox(height: 48),
              
              // Biometric & Forgot
              Column(
                children: [
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(40),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(color: AppTheme.primaryGold.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: const Icon(Symbols.fingerprint, color: AppTheme.primaryGold, size: 40),
                        ),
                        const SizedBox(height: 8),
                        const Text('BIOMÉTRIE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppTheme.primaryGold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Code PIN oublié ?',
                      style: TextStyle(color: AppTheme.grayText, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Security Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Symbols.lock, size: 14, color: AppTheme.grayText),
                  const SizedBox(width: 8),
                  Text(
                    'CONNEXION SÉCURISÉE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppTheme.grayText.withValues(alpha: 0.6)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['1', '2', '3'].map((n) => _buildNumButton(n)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['4', '5', '6'].map((n) => _buildNumButton(n)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['7', '8', '9'].map((n) => _buildNumButton(n)).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 80),
              _buildNumButton('0'),
              SizedBox(
                width: 80,
                height: 80,
                child: IconButton(
                  onPressed: _onBackspace,
                  icon: const Icon(Symbols.backspace, color: AppTheme.grayText, size: 28),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumButton(String label) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.transparent),
      ),
      child: InkWell(
        onTap: () => _onNumberPressed(label),
        borderRadius: BorderRadius.circular(40),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: AppTheme.textDark),
          ),
        ),
      ),
    );
  }
}
