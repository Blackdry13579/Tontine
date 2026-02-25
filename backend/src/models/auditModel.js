const pool = require('../config/database');

const create = async (auditData) => {
    const { user_id, tontine_id, action, details, ip_address } = auditData;
    const { rows } = await pool.query(
        `INSERT INTO audit_logs (user_id, tontine_id, action, details, ip_address)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING *`,
        [user_id, tontine_id, action, JSON.stringify(details), ip_address]
    );
    return rows[0];
};

const findByTontineId = async (tontineId) => {
    const { rows } = await pool.query(
        `SELECT a.*, u.nom, u.prenom
     FROM audit_logs a
     LEFT JOIN users u ON a.user_id = u.id
     WHERE a.tontine_id = $1
     ORDER BY a.date_creation DESC`,
        [tontineId]
    );
    return rows;
};

module.exports = {
    create,
    findByTontineId,
};
