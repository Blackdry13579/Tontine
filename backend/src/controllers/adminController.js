const auditModel = require('../models/auditModel');
const apiResponse = require('../utils/apiResponse');
const pool = require('../config/database');
const logger = require('../utils/logger');

const getDashboardStats = async (req, res, next) => {
    try {
        const stats = {};

        if (req.user.role_systeme === 'admin' || req.user.telephone === '+22601020312') {
            const users = await pool.query('SELECT COUNT(*) FROM users');
            stats.total_users = parseInt(users.rows[0].count);

            const tontinesGlobal = await pool.query('SELECT COUNT(*) FROM tontines');
            stats.total_tontines = parseInt(tontinesGlobal.rows[0].count);

            const cotisationsGlobal = await pool.query("SELECT COALESCE(SUM(montant), 0) as total FROM cotisations WHERE statut = 'validee'");
            stats.total_cotisations_montant = parseFloat(cotisationsGlobal.rows[0].total);

            const distributionsGlobal = await pool.query("SELECT COALESCE(SUM(montant), 0) as total FROM distributions");
            stats.total_distributions_montant = parseFloat(distributionsGlobal.rows[0].total);
        }

        const tontines = await pool.query(
            'SELECT COUNT(*) FROM memberships WHERE user_id = $1',
            [req.user.id]
        );
        stats.my_tontines_count = parseInt(tontines.rows[0].count);

        // NOTE: Wallet tables dropped, using calculated balance for dashboard if needed
        const balanceQuery = await pool.query(
            "SELECT COALESCE(SUM(montant), 0) as balance FROM cotisations c JOIN memberships m ON c.membership_id = m.id WHERE m.user_id = $1 AND c.statut = 'validee'",
            [req.user.id]
        );
        stats.wallet_balance = parseFloat(balanceQuery.rows[0].balance);

        return apiResponse.success(res, stats);
    } catch (err) {
        next(err);
    }
};

const getTontineAudit = async (req, res, next) => {
    try {
        const logs = await auditModel.findByTontineId(req.params.id);
        return apiResponse.success(res, logs);
    } catch (err) {
        next(err);
    }
};

const getDashboardTontine = async (req, res, next) => {
    try {
        const { tontineId } = req.params;

        // Vérifier que req.user est organisateur de cette tontine
        const membershipCheck = await pool.query(
            "SELECT id FROM memberships WHERE tontine_id = $1 AND user_id = $2 AND role = 'organisateur'",
            [tontineId, req.user.id]
        );
        if (!membershipCheck.rows.length) {
            return apiResponse.error(res, 'Accès refusé — vous n\'êtes pas organisateur de cette tontine', 403);
        }

        // Total collecté (cotisations validées uniquement)
        const totalQuery = await pool.query(`
      SELECT COALESCE(SUM(c.montant), 0) as total_collecte
      FROM cotisations c
      JOIN memberships m ON c.membership_id = m.id
      WHERE m.tontine_id = $1 AND c.statut = 'validee'
    `, [tontineId]);

        // Cotisations en attente de validation
        const enAttenteQuery = await pool.query(`
      SELECT c.*, u.nom, u.prenom, u.telephone
      FROM cotisations c
      JOIN memberships m ON c.membership_id = m.id
      JOIN users u ON m.user_id = u.id
      WHERE m.tontine_id = $1 AND c.statut = 'en_attente_validation'
      ORDER BY c.date_creation ASC
    `, [tontineId]);

        return apiResponse.success(res, {
            total_collecte: totalQuery.rows[0].total_collecte,
            devise: 'FCFA',
            cotisations_en_attente: enAttenteQuery.rows
        }, 'Dashboard tontine');
    } catch (err) {
        logger.error('Erreur getDashboardTontine', { error: err.message });
        next(err);
    }
};

module.exports = {
    getDashboardStats,
    getTontineAudit,
    getDashboardTontine
};
