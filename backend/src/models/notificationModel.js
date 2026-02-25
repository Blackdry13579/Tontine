const pool = require('../config/database');

const findByUserId = async (userId) => {
    const { rows } = await pool.query(
        'SELECT * FROM notifications WHERE user_id = $1 ORDER BY date_creation DESC',
        [userId]
    );
    return rows;
};

const create = async (notifData) => {
    const { user_id, type, titre, message, data } = notifData;
    const { rows } = await pool.query(
        `INSERT INTO notifications (user_id, type, titre, message, data)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING *`,
        [user_id, type, titre, message, JSON.stringify(data)]
    );
    return rows[0];
};

const markAsRead = async (id, userId) => {
    const { rows } = await pool.query(
        'UPDATE notifications SET est_lue = true WHERE id = $1 AND user_id = $2 RETURNING *',
        [id, userId]
    );
    return rows[0];
};

const markAllAsRead = async (userId) => {
    const { rowCount } = await pool.query(
        'UPDATE notifications SET est_lue = true WHERE user_id = $1',
        [userId]
    );
    return rowCount;
};

const getReminderSettings = async (userId) => {
    const { rows } = await pool.query(
        'SELECT * FROM reminder_settings WHERE user_id = $1',
        [userId]
    );
    return rows[0];
};

const updateReminderSettings = async (userId, settings) => {
    const { jours_avant, heure_rappel, push_active, sms_active } = settings;
    const { rows } = await pool.query(
        `INSERT INTO reminder_settings (user_id, jours_avant, heure_rappel, push_active, sms_active)
     VALUES ($1, $2, $3, $4, $5)
     ON CONFLICT (user_id) DO UPDATE SET
       jours_avant = EXCLUDED.jours_avant,
       heure_rappel = EXCLUDED.heure_rappel,
       push_active = EXCLUDED.push_active,
       sms_active = EXCLUDED.sms_active,
       date_modification = NOW()
     RETURNING *`,
        [userId, jours_avant, heure_rappel, push_active, sms_active]
    );
    return rows[0];
};

module.exports = {
    findByUserId,
    create,
    markAsRead,
    markAllAsRead,
    getReminderSettings,
    updateReminderSettings,
};
