const pool = require('../config/database');

const create = async (cycleData) => {
    const { tontine_id, numero_cycle, date_debut, date_fin } = cycleData;
    const { rows } = await pool.query(
        `INSERT INTO cycles (tontine_id, numero_cycle, date_debut, date_fin)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
        [tontine_id, numero_cycle, date_debut, date_fin]
    );
    return rows[0];
};

const findByTontineId = async (tontineId) => {
    const { rows } = await pool.query(
        'SELECT * FROM cycles WHERE tontine_id = $1 ORDER BY numero_cycle DESC',
        [tontineId]
    );
    return rows;
};

const findById = async (id) => {
    const { rows } = await pool.query(
        'SELECT * FROM cycles WHERE id = $1',
        [id]
    );
    return rows[0];
};

const update = async (id, cycleData) => {
    const fields = [];
    const values = [];
    let idx = 1;

    for (const [key, value] of Object.entries(cycleData)) {
        if (['statut', 'montant_collecte'].includes(key)) {
            fields.push(`${key} = $${idx}`);
            values.push(value);
            idx++;
        }
    }

    if (fields.length === 0) return null;

    values.push(id);
    const { rows } = await pool.query(
        `UPDATE cycles SET ${fields.join(', ')} WHERE id = $${idx} RETURNING *`,
        values
    );
    return rows[0];
};

module.exports = {
    create,
    findByTontineId,
    findById,
    update,
};
