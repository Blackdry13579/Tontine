const pool = require('../config/database');

const create = async (distributionData) => {
    const {
        cycle_id, membership_id, montant, statut,
        moyen_distribution, reference_transaction, date_distribution
    } = distributionData;

    const { rows } = await pool.query(
        `INSERT INTO distributions (
      cycle_id, membership_id, montant, statut,
      moyen_distribution, reference_transaction, date_distribution
    ) VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING *`,
        [
            cycle_id, membership_id, montant, statut || 'planifiee',
            moyen_distribution, reference_transaction, date_distribution
        ]
    );
    return rows[0];
};

const findByCycleId = async (cycleId) => {
    const { rows } = await pool.query(
        `SELECT d.*, u.nom, u.prenom
     FROM distributions d
     JOIN memberships m ON d.membership_id = m.id
     JOIN users u ON m.user_id = u.id
     WHERE d.cycle_id = $1`,
        [cycleId]
    );
    return rows;
};

const findById = async (id) => {
    const { rows } = await pool.query(
        'SELECT * FROM distributions WHERE id = $1',
        [id]
    );
    return rows[0];
};

const update = async (id, distributionData) => {
    const fields = [];
    const values = [];
    let idx = 1;

    for (const [key, value] of Object.entries(distributionData)) {
        if (['statut', 'reference_transaction', 'date_distribution', 'moyen_distribution'].includes(key)) {
            fields.push(`${key} = $${idx}`);
            values.push(value);
            idx++;
        }
    }

    if (fields.length === 0) return null;

    values.push(id);
    const { rows } = await pool.query(
        `UPDATE distributions SET ${fields.join(', ')} WHERE id = $${idx} RETURNING *`,
        values
    );
    return rows[0];
};

module.exports = {
    create,
    findByCycleId,
    findById,
    update,
};
