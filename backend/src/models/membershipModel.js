const pool = require('../config/database');

const create = async (membershipData) => {
    const { tontine_id, user_id, role, position_ordre } = membershipData;
    const { rows } = await pool.query(
        `INSERT INTO memberships (tontine_id, user_id, role, position_ordre)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
        [tontine_id, user_id, role || 'membre', position_ordre]
    );
    return rows[0];
};

const findByTontineId = async (tontineId) => {
    const { rows } = await pool.query(
        `SELECT m.*, u.nom, u.prenom, u.photo_url, u.telephone
     FROM memberships m
     JOIN users u ON m.user_id = u.id
     WHERE m.tontine_id = $1
     ORDER BY m.position_ordre NULLS LAST, m.date_adhesion ASC`,
        [tontineId]
    );
    return rows;
};

const findByUserAndTontine = async (userId, tontineId) => {
    const { rows } = await pool.query(
        'SELECT * FROM memberships WHERE user_id = $1 AND tontine_id = $2',
        [userId, tontineId]
    );
    return rows[0];
};

const update = async (id, membershipData) => {
    const fields = [];
    const values = [];
    let idx = 1;

    for (const [key, value] of Object.entries(membershipData)) {
        if (['role', 'statut', 'position_ordre'].includes(key)) {
            fields.push(`${key} = $${idx}`);
            values.push(value);
            idx++;
        }
    }

    if (fields.length === 0) return null;

    values.push(id);
    const { rows } = await pool.query(
        `UPDATE memberships SET ${fields.join(', ')} WHERE id = $${idx} RETURNING *`,
        values
    );
    return rows[0];
};

const findById = async (id) => {
    const { rows } = await pool.query(
        `SELECT m.*, u.nom, u.prenom, u.telephone
     FROM memberships m
     JOIN users u ON m.user_id = u.id
     WHERE m.id = $1`,
        [id]
    );
    return rows[0];
};

const deleteMembership = async (id) => {
    const { rowCount } = await pool.query('DELETE FROM memberships WHERE id = $1', [id]);
    return rowCount > 0;
};

module.exports = {
    create,
    findByTontineId,
    findByUserAndTontine,
    findById,
    update,
    deleteMembership
};
