/*
NOTE : Le "wallet" AURUM n'est PAS un compte bancaire.
C'est un historique visuel des cotisations de l'utilisateur.
L'argent est reçu directement par l'organisateur via Mobile Money.
Le backend calcule uniquement des statistiques d'affichage.

TODO V2 : Intégrer l'API LigdiCash pour automatiser les paiements.
*/

const pool = require('../config/database');

async function getHistoriqueMembre(userId) {
  const query = `
    SELECT * FROM (
      SELECT
        c.id,
        c.montant,
        c.statut,
        c.date_creation,
        'cotisation' as type,
        t.nom as tontine_nom,
        cy.numero_cycle
      FROM cotisations c
      JOIN memberships m ON c.membership_id = m.id
      JOIN tontines t ON m.tontine_id = t.id
      JOIN cycles cy ON c.cycle_id = cy.id
      WHERE m.user_id = $1

      UNION ALL

      SELECT
        d.id,
        d.montant,
        d.statut,
        d.date_creation,
        'distribution' as type,
        t.nom as tontine_nom,
        cy.numero_cycle
      FROM distributions d
      JOIN memberships m ON d.membership_id = m.id
      JOIN tontines t ON m.tontine_id = t.id
      JOIN cycles cy ON d.cycle_id = cy.id
      WHERE m.user_id = $1
    ) AS h
    ORDER BY h.date_creation DESC
  `;
  return pool.query(query, [userId]);
}

async function getResumeFinancierMembre(userId) {
  const query = `
    WITH stats AS (
      SELECT 
        COALESCE(SUM(CASE WHEN c.statut = 'validee' THEN c.montant ELSE 0 END), 0) as total_cotisations_valide,
        COALESCE(SUM(CASE WHEN c.statut = 'en_attente_validation' THEN c.montant ELSE 0 END), 0) as total_cotisations_en_attente,
        COUNT(CASE WHEN c.statut = 'validee' THEN 1 END) as nb_cotisations,
        COUNT(CASE WHEN c.statut = 'en_retard' THEN 1 END) as nb_retards
      FROM cotisations c
      JOIN memberships m ON c.membership_id = m.id
      WHERE m.user_id = $1
    ),
    gains AS (
      SELECT 
        COALESCE(SUM(CASE WHEN d.statut = 'effectuee' THEN d.montant ELSE 0 END), 0) as total_gains
      FROM distributions d
      JOIN memberships m ON d.membership_id = m.id
      WHERE m.user_id = $1
    )
    SELECT 
      (total_cotisations_valide + total_gains) as total_valide,
      total_cotisations_en_attente as total_en_attente,
      nb_cotisations as nombre_paiements,
      nb_retards as nombre_retards
    FROM stats, gains
  `;
  return pool.query(query, [userId]);
}

module.exports = { getHistoriqueMembre, getResumeFinancierMembre };
