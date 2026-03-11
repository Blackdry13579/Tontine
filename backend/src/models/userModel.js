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
    const { firebase_uid, telephone, email, nom, prenom, photo_url, role_systeme, ville, profil_complet } = userData;
    const { rows } = await pool.query(
        `INSERT INTO users (firebase_uid, telephone, email, nom, prenom, photo_url, role_systeme, ville, profil_complet)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
     RETURNING *`,
        [firebase_uid, telephone, email, nom, prenom, photo_url, role_systeme || 'membre', ville, profil_complet || false]
    );
    return rows[0];
};

const update = async (id, userData) => {
    const { nom, prenom, email, ville, photo_url } = userData;

    // SQL attendu par le workflow :
    // UPDATE users SET nom=$1, prenom=$2, email=$3, ville=$4, photo_url=$5,
    // profil_complet = CASE WHEN $1 IS NOT NULL AND $2 IS NOT NULL THEN true ELSE profil_complet END,
    // date_modification = NOW()
    // WHERE id=$6

    const { rows } = await pool.query(
        `UPDATE users 
         SET nom = COALESCE($1, nom), 
             prenom = COALESCE($2, prenom), 
             email = COALESCE($3, email), 
             ville = COALESCE($4, ville), 
             photo_url = COALESCE($5, photo_url),
             profil_complet = CASE WHEN $1 IS NOT NULL AND $2 IS NOT NULL THEN true ELSE profil_complet END,
             date_modification = NOW()
         WHERE id = $6
         RETURNING *`,
        [nom, prenom, email, ville, photo_url, id]
    );
    return rows[0];
};

module.exports = {
    findByFirebaseUid,
    findById,
    create,
    update,
};
