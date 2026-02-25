/*
NOTE : Le "wallet" AURUM n'est PAS un compte bancaire.
C'est un historique visuel des cotisations de l'utilisateur.
L'argent est reçu directement par l'organisateur via Mobile Money.
Le backend calcule uniquement des statistiques d'affichage.

TODO V2 : Intégrer l'API LigdiCash pour automatiser les paiements.
*/

const pool = require('../config/database');

async function getHistoriqueMembre(userId) {
    // Retourne l'historique des cotisations avec le total calculé
    const query = `
    SELECT
      c.id,
      c.montant,
      c.statut,
      c.nom_expediteur,
      c.prenom_expediteur,
      c.telephone_expediteur,
      c.date_creation,
      c.date_paiement,
      t.nom as tontine_nom,
      cy.numero_cycle
    FROM cotisations c
    JOIN memberships m ON c.membership_id = m.id
    JOIN tontines t ON m.tontine_id = t.id
    JOIN cycles cy ON c.cycle_id = cy.id
    WHERE m.user_id = $1
    ORDER BY c.date_creation DESC
  `;
    return pool.query(query, [userId]);
}

async function getResumeFinancierMembre(userId) {
    // Calcule le résumé financier affiché dans le dashboard membre
    const query = `
    SELECT
      COALESCE(SUM(CASE WHEN statut = 'validee' THEN montant ELSE 0 END), 0) as total_valide,
      COALESCE(SUM(CASE WHEN statut = 'en_attente_validation' THEN montant ELSE 0 END), 0) as total_en_attente,
      COUNT(CASE WHEN statut = 'validee' THEN 1 END) as nombre_paiements,
      COUNT(CASE WHEN statut = 'en_retard' THEN 1 END) as nombre_retards
    FROM cotisations c
    JOIN memberships m ON c.membership_id = m.id
    WHERE m.user_id = $1
  `;
    return pool.query(query, [userId]);
}

module.exports = { getHistoriqueMembre, getResumeFinancierMembre };
