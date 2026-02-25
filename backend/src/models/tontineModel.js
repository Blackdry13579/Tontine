const pool = require('../config/database');

const create = async (tontineData) => {
    const {
        nom, description, montant_cotisation, frequence,
        nombre_membres_max, date_debut, code_invitation, created_by
    } = tontineData;

    const { rows } = await pool.query(
        `INSERT INTO tontines (
      nom, description, montant_cotisation, frequence,
      nombre_membres_max, date_debut, code_invitation, created_by
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
    RETURNING *`,
        [nom, description, montant_cotisation, frequence, nombre_membres_max, date_debut, code_invitation, created_by]
    );
    return rows[0];
};

const findAll = async (options = {}) => {
    let query = `
    SELECT t.* FROM tontines t
    JOIN memberships m ON t.id = m.tontine_id
    WHERE m.user_id = $1
  `;
    const params = [options.userId];
    let idx = 2;

    if (options.statut) {
        query += ` AND t.statut = $${idx}`;
        params.push(options.statut);
        idx++;
    }

    query += ' ORDER BY t.date_creation DESC';
    const { rows } = await pool.query(query, params);
    return rows;
};

const findById = async (id, userId) => {
    // Get basic tontine info
    const { rows } = await pool.query(
        `SELECT t.*, m.role as user_role, m.statut as user_membership_statut
     FROM tontines t
     LEFT JOIN memberships m ON t.id = m.tontine_id AND m.user_id = $2
     WHERE t.id = $1`,
        [id, userId]
    );

    if (rows.length === 0) return null;

    const tontine = rows[0];

    // Add stats (example of DRY view)
    const stats = await pool.query(
        `SELECT 
      (SELECT COUNT(*) FROM memberships WHERE tontine_id = $1) as total_membres,
      (SELECT SUM(montant_collecte) FROM cycles WHERE tontine_id = $1) as total_collecte`,
        [id]
    );

    tontine.stats = stats.rows[0];
    return tontine;
};

const update = async (id, tontineData) => {
    const fields = [];
    const values = [];
    let idx = 1;

    const allowedFields = ['nom', 'description', 'montant_cotisation', 'frequence', 'nombre_membres_max', 'date_debut', 'statut', 'penalites_activees', 'montant_penalite', 'code_invitation'];

    for (const [key, value] of Object.entries(tontineData)) {
        if (allowedFields.includes(key)) {
            fields.push(`${key} = $${idx}`);
            values.push(value);
            idx++;
        }
    }

    if (fields.length === 0) return null;

    values.push(id);
    const { rows } = await pool.query(
        `UPDATE tontines SET ${fields.join(', ')}, date_modification = NOW() WHERE id = $${idx} RETURNING *`,
        values
    );
    return rows[0];
};

module.exports = {
    create,
    findAll,
    findById,
    update,
};
