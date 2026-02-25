const cotisationModel = require('../models/cotisationModel');
const membershipModel = require('../models/membershipModel');
const apiResponse = require('../utils/apiResponse');
const logger = require('../utils/logger');
const pool = require('../config/database');

const initiatePayment = async (req, res, next) => {
    try {
        const { cycle_id, montant, nom_expediteur, prenom_expediteur, telephone_expediteur, preuve_paiement_url } = req.body;

        // Find membership for this user in the tontine of the cycle
        const { rows } = await pool.query(
            `SELECT m.id FROM memberships m
       JOIN cycles c ON m.tontine_id = c.tontine_id
       WHERE m.user_id = $1 AND c.id = $2`,
            [req.user.id, cycle_id]
        );

        if (rows.length === 0) return apiResponse.error(res, 'Vous n\'etes pas membre de cette tontine', 403);

        const membership_id = rows[0].id;

        const cotisation = await cotisationModel.create({
            cycle_id,
            membership_id,
            montant,
            nom_expediteur,
            prenom_expediteur,
            telephone_expediteur,
            preuve_paiement_url,
            statut: 'en_attente_validation'
        });

        logger.info(`Paiement manuel initie par ${req.user.telephone} pour le cycle ${cycle_id}`);
        return apiResponse.success(res, cotisation, 'Paiement soumis pour validation', 201);
    } catch (err) {
        next(err);
    }
};

const getCycleCotisations = async (req, res, next) => {
    try {
        const cycleId = req.params.id;
        const options = {};

        const { rows } = await pool.query(
            `SELECT m.role FROM memberships m 
       JOIN cycles c ON m.tontine_id = c.tontine_id
       WHERE m.user_id = $1 AND c.id = $2`,
            [req.user.id, cycleId]
        );

        if (rows.length === 0) return apiResponse.error(res, 'Acces refuse', 403);

        if (rows[0].role !== 'organisateur') {
            const m = await membershipModel.findByUserAndTontine(req.user.id, (await pool.query('SELECT tontine_id FROM cycles WHERE id = $1', [cycleId])).rows[0].tontine_id);
            options.membershipId = m.id;
        }

        const cotisations = await cotisationModel.findByCycleId(cycleId, options);
        return apiResponse.success(res, cotisations);
    } catch (err) {
        next(err);
    }
};

const getHistory = async (req, res, next) => {
    try {
        const history = await cotisationModel.findHistory(req.user.id);
        return apiResponse.success(res, history);
    } catch (err) {
        next(err);
    }
};

const getPendingValidations = async (req, res, next) => {
    try {
        const pending = await cotisationModel.findPendingValidations(req.user.id);
        return apiResponse.success(res, pending);
    } catch (err) {
        next(err);
    }
};

const validateCotisation = async (req, res, next) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        const cotisation = await cotisationModel.update(req.params.id, {
            statut: 'validee',
            validated_by: req.user.id,
            date_validation: new Date(),
            date_paiement: new Date()
        });

        if (!cotisation) {
            await client.query('ROLLBACK');
            return apiResponse.error(res, 'Cotisation non trouvee', 404);
        }

        // Update cycle amount
        await client.query(
            'UPDATE cycles SET montant_collecte = montant_collecte + $1 WHERE id = $2',
            [cotisation.montant, cotisation.cycle_id]
        );

        await client.query('COMMIT');
        logger.info(`Cotisation ${req.params.id} validee par ${req.user.id}`);
        return apiResponse.success(res, cotisation, 'Cotisation validee');
    } catch (err) {
        await client.query('ROLLBACK');
        next(err);
    } finally {
        client.release();
    }
};

const rejectCotisation = async (req, res, next) => {
    try {
        const { motif } = req.body;
        const cotisation = await cotisationModel.update(req.params.id, {
            statut: 'rejetee',
            motif_rejet: motif,
            validated_by: req.user.id,
            date_validation: new Date()
        });

        if (!cotisation) return apiResponse.error(res, 'Cotisation non trouvee', 404);

        logger.info(`Cotisation ${req.params.id} rejetee par ${req.user.id}`);
        return apiResponse.success(res, cotisation, 'Cotisation rejetee');
    } catch (err) {
        next(err);
    }
};

/*
TODO: V2 — Paiement automatique LigdiCash
Ce code est désactivé pour le MVP.
Le MVP utilise la validation manuelle par l'organisateur.
À réactiver quand l'API LigdiCash sera intégrée.
*/

module.exports = {
    initiatePayment,
    getCycleCotisations,
    getHistory,
    getPendingValidations,
    validateCotisation,
    rejectCotisation
};
