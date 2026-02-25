const pool = require('../config/database');

const findByFirebaseUid = async (firebaseUid) => {
    const { rows } = await pool.query(
        'SELECT * FROM users WHERE firebase_uid = $1',
        [firebaseUid]
    );
    return rows[0];
};

const findById = async (id) => {
    const { rows } = await pool.query(
        'SELECT * FROM users WHERE id = $1',
        [id]
    );
    return rows[0];
};

const create = async (userData) => {
    const { firebase_uid, telephone, email, nom, prenom, photo_url, role_systeme, ville, adresse, profil_complet } = userData;
    const { rows } = await pool.query(
        `INSERT INTO users (firebase_uid, telephone, email, nom, prenom, photo_url, role_systeme, ville, adresse, profil_complet)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
     RETURNING *`,
        [firebase_uid, telephone, email, nom, prenom, photo_url, role_systeme || 'membre', ville, adresse, profil_complet || false]
    );
    return rows[0];
};

const update = async (id, userData) => {
    const fields = [];
    const values = [];
    let idx = 1;

    const allowedFields = ['nom', 'prenom', 'photo_url', 'email', 'telephone', 'ville', 'adresse', 'profil_complet'];

    for (const [key, value] of Object.entries(userData)) {
        if (allowedFields.includes(key)) {
            fields.push(`${key} = $${idx}`);
            values.push(value);
            idx++;
        }
    }

    if (fields.length === 0) return null;

    values.push(id);
    const { rows } = await pool.query(
        `UPDATE users SET ${fields.join(', ')}, date_modification = NOW() WHERE id = $${idx} RETURNING *`,
        values
    );
    return rows[0];
};

module.exports = {
    findByFirebaseUid,
    findById,
    create,
    update,
};
