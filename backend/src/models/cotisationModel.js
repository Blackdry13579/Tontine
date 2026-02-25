const pool = require('../config/database');

const create = async (cotisationData) => {
    const {
        cycle_id, membership_id, montant, date_echeance,
        statut, moyen_paiement, reference_transaction, preuve_paiement_url,
        nom_expediteur, prenom_expediteur, telephone_expediteur
    } = cotisationData;

    const { rows } = await pool.query(
        `INSERT INTO cotisations (
      cycle_id, membership_id, montant, date_echeance,
      statut, moyen_paiement, reference_transaction, preuve_paiement_url,
      nom_expediteur, prenom_expediteur, telephone_expediteur
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
    RETURNING *`,
        [
            cycle_id, membership_id, montant, date_echeance,
            statut || 'en_attente_paiement', moyen_paiement, reference_transaction, preuve_paiement_url,
            nom_expediteur, prenom_expediteur, telephone_expediteur
        ]
    );
    return rows[0];
};

const findByCycleId = async (cycleId, options = {}) => {
    let query = `
    SELECT c.*, u.nom, u.prenom, m.role
    FROM cotisations c
    JOIN memberships m ON c.membership_id = m.id
    JOIN users u ON m.user_id = u.id
    WHERE c.cycle_id = $1
  `;
    const params = [cycleId];
    let idx = 2;

    if (options.membershipId) {
        query += ` AND c.membership_id = $${idx}`;
        params.push(options.membershipId);
        idx++;
    }

    const { rows } = await pool.query(query, params);
    return rows;
};

const findHistory = async (userId) => {
    const { rows } = await pool.query(
        `SELECT c.*, t.nom as tontine_nom, cy.numero_cycle
     FROM cotisations c
     JOIN memberships m ON c.membership_id = m.id
     JOIN cycles cy ON c.cycle_id = cy.id
     JOIN tontines t ON cy.tontine_id = t.id
     WHERE m.user_id = $1
     ORDER BY c.date_creation DESC`,
        [userId]
    );
    return rows;
};

const findPendingValidations = async (organisateurId) => {
    const { rows } = await pool.query(
        `SELECT c.*, u.nom, u.prenom, t.nom as tontine_nom
     FROM cotisations c
     JOIN memberships m ON c.membership_id = m.id
     JOIN users u ON m.user_id = u.id
     JOIN cycles cy ON c.cycle_id = cy.id
     JOIN tontines t ON cy.tontine_id = t.id
     JOIN memberships m2 ON t.id = m2.tontine_id
     WHERE m2.user_id = $1 AND m2.role = 'organisateur'
     AND c.statut = 'en_attente_validation'
     ORDER BY c.date_creation ASC`,
        [organisateurId]
    );
    return rows;
};

const update = async (id, cotisationData) => {
    const fields = [];
    const values = [];
    let idx = 1;

    const allowedFields = ['statut', 'date_paiement', 'validated_by', 'date_validation', 'preuve_paiement_url', 'reference_transaction', 'moyen_paiement', 'motif_rejet'];

    for (const [key, value] of Object.entries(cotisationData)) {
        if (allowedFields.includes(key)) {
            fields.push(`${key} = $${idx}`);
            values.push(value);
            idx++;
        }
    }

    if (fields.length === 0) return null;

    values.push(id);
    const { rows } = await pool.query(
        `UPDATE cotisations SET ${fields.join(', ')} WHERE id = $${idx} RETURNING *`,
        values
    );
    return rows[0];
};

async function getSommeValidee(userId) {
    const query = `
    SELECT
      COALESCE(SUM(c.montant), 0) as total_valide,
      COALESCE(SUM(CASE WHEN c.statut = 'en_attente_validation' THEN c.montant ELSE 0 END), 0) as total_en_attente,
      COUNT(CASE WHEN c.statut = 'validee' THEN 1 END) as nombre_paiements_valides
    FROM cotisations c
    JOIN memberships m ON c.membership_id = m.id
    WHERE m.user_id = $1 AND c.statut = 'validee'
  `;
    return pool.query(query, [userId]);
}

async function getCotisationsEnAttente(tontineId) {
    const query = `
    SELECT
      c.*,
      u.nom, u.prenom, u.telephone,
      t.nom as tontine_nom
    FROM cotisations c
    JOIN memberships m ON c.membership_id = m.id
    JOIN users u ON m.user_id = u.id
    JOIN tontines t ON m.tontine_id = t.id
    WHERE m.tontine_id = $1
    AND c.statut = 'en_attente_validation'
    ORDER BY c.date_creation ASC
  `;
    return pool.query(query, [tontineId]);
}

module.exports = {
    create,
    findByCycleId,
    findHistory,
    findPendingValidations,
    update,
    getSommeValidee,
    getCotisationsEnAttente
};
