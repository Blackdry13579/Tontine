import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../theme/app_theme.dart';
import '../../shared/widgets/app_bottom_nav.dart';

import 'report_problem_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const List<Map<String, String>> _faqs = [
    {
      'q': 'Comment créer une tontine ?',
      'a': 'Allez dans l\'onglet Tontines, cliquez sur le bouton "+" ou "Créer une tontine", et remplissez les détails comme le nom, le montant de la cotisation et la fréquence.'
    },
    {
      'q': 'Comment inviter des membres ?',
      'a': 'Une fois votre tontine créée, un code d\'invitation unique est généré. Partagez ce code avec vos amis pour qu\'ils puissent rejoindre le groupe.'
    },
    {
      'q': 'Quand est-ce que je reçois ma distribution ?',
      'a': 'La distribution se fait selon l\'ordre défini lors du tirage au sort initial. Chaque membre reçoit le pot total une fois durant le cycle de la tontine.'
    },
    {
      'q': 'Comment soumettre une cotisation ?',
      'a': 'Allez dans les détails de votre tontine, cliquez sur "Payer ma cotisation" et téléchargez une capture d\'écran de votre preuve de transfert.'
    },
    {
      'q': 'Que se passe-t-il si je rate un paiement ?',
      'a': 'En cas de retard, des pénalités peuvent être appliquées selon les règles du groupe. Contactez l\'organisateur pour trouver un arrangement.'
    },
    {
      'q': 'Puis-je quitter une tontine en cours ?',
      'a': 'Il est généralement impossible de quitter une tontine avant la fin du cycle par respect pour les autres membres. Un remplaçant doit être trouvé.'
    },
    {
      'q': 'Comment est défini l\'ordre des gagnants ?',
      'a': 'L\'ordre est défini par un tirage au sort transparent effectué au lancement de la tontine par l\'algorithme AURUM.'
    },
    {
      'q': 'Quels sont les frais de service ?',
      'a': 'AURUM prélève une commission minime sur chaque tontine pour garantir la maintenance et la sécurité du service. Voir les détails lors de la création.'
    },
    {
      'q': 'Mes données sont-elles sécurisées ?',
      'a': 'Oui, toutes vos données sont chiffrées et nous utilisons des protocoles de sécurité bancaire pour protéger vos informations.'
    },
    {
      'q': 'Comment changer mon code PIN ?',
      'a': 'Allez dans Profil > Sécurité > Modifier le code PIN. Vous devrez saisir votre ancien code avant d\'en définir un nouveau.'
    },
    {
      'q': 'Puis-je avoir plusieurs tontines ?',
      'a': 'Oui, vous pouvez participer à autant de tontines que votre budget le permet. Gérez-les toutes depuis votre tableau de bord.'
    },
    {
      'q': 'Comment valider le paiement d\'un membre ?',
      'a': 'Si vous êtes l\'organisateur, allez dans l\'onglet Admin de la tontine pour voir les preuves de paiement et les valider d\'un clic.'
    },
    {
      'q': 'Que faire en cas de litige ?',
      'a': 'Essayez d\'abord de discuter avec les membres. Si le problème persiste, utilisez la fonction "Signaler un problème" pour contacter notre support.'
    },
    {
      'q': 'Comment fonctionne le portefeuille ?',
      'a': 'Le Wallet affiche votre solde disponible issu des gains de tontines. Vous pouvez retirer ces fonds vers votre compte mobile money.'
    },
    {
      'q': 'Puis-je retirer mon argent à tout moment ?',
      'a': 'Vous pouvez retirer les fonds présents dans votre Wallet à tout moment. Les cotisations bloquées dans une tontine ne sont pas retirables avant votre tour.'
    },
    {
      'q': 'Comment activer la biométrie ?',
      'a': 'Allez dans Profil > Sécurité et activez le toggle "Activer la biométrie". Votre téléphone doit supporter Face ID ou l\'empreinte digitale.'
    },
    {
      'q': 'Pourquoi ma preuve a été rejetée ?',
      'a': 'Une preuve est rejetée si elle est illisible, si le montant est incorrect ou si elle a déjà été utilisée. Contactez votre organisateur.'
    },
    {
      'q': 'Comment supprimer mon compte ?',
      'a': 'Allez dans Profil > Gestion du compte > Se déconnecter, puis contactez le support pour une demande de suppression définitive.'
    },
    {
      'q': 'Comment contacter le support ?',
      'a': 'Utilisez la section "Contacter le support" ci-dessous pour nous envoyer un email ou réservez un créneau d\'appel avec nos experts.'
    },
    {
      'q': 'Y a-t-il une limite de montant ?',
      'a': 'Non, AURUM n\'impose pas de limite arbitraire, mais nous conseillons de rester dans des montants raisonnables pour la sécurité du groupe.'
    },
  ];

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
            'Centre d\'aide',
            style: TextStyle(
              color: AppTheme.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- CATEGORIES CARD ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildHelpTile(
                      icon: Symbols.quiz,
                      iconColor: AppTheme.primaryGold,
                      title: 'Foire aux questions (FAQ)',
                      subtitle: 'Trouvez des réponses immédiates',
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 72, color: Color(0xFFF1F5F9)),
                    _buildHelpTile(
                      icon: Symbols.support_agent,
                      iconColor: Colors.blue,
                      title: 'Signaler un problème',
                      subtitle: 'Discutez avec notre équipe',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReportProblemScreen()),
                      ),
                    ),
                    const Divider(height: 1, indent: 72, color: Color(0xFFF1F5F9)),
                    _buildHelpTile(
                      icon: Symbols.menu_book,
                      iconColor: const Color(0xFF1B5E20),
                      title: 'Guide d\'utilisation',
                      subtitle: 'Apprenez à maîtriser AURUM',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // --- FAQ SECTION ---
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 16),
                  child: Text(
                    'Questions fréquentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
              ),
              
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _faqs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                    ),
                    child: ExpansionTile(
                      shape: const RoundedRectangleBorder(side: BorderSide.none),
                      collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                      title: Text(
                        _faqs[index]['q']!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      iconColor: AppTheme.primaryGold,
                      collapsedIconColor: Colors.grey,
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        Text(
                          _faqs[index]['a']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // --- TICKET CARD ---
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1B5E20).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Besoin d\'un appel ?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Nos experts sont disponibles de 9h à 18h pour vous accompagner.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1B5E20),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'Prendre rendez-vous',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Opacity(
                      opacity: 0.2,
                      child: Icon(
                        Symbols.headset_mic,
                        size: 120,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      ),
    );
  }

  Widget _buildHelpTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Symbols.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
