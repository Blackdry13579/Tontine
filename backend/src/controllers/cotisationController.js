const cotisationModel = require('../models/cotisationModel');
const membershipModel = require('../models/membershipModel');
const notificationModel = require('../models/notificationModel');
const apiResponse = require('../utils/apiResponse');
const logger = require('../utils/logger');
const pool = require('../config/database');

const initiatePayment = async (req, res, next) => {
    try {
        const { cycle_id, moyen_paiement, telephone_expediteur, nom_expediteur, prenom_expediteur } = req.body;

        // 1. Récupérer le montant automatiquement depuis la tontine
        const { rows: amountRows } = await pool.query(
            `SELECT t.montant_cotisation, t.id as tontine_id
             FROM tontines t
             JOIN memberships m ON m.tontine_id = t.id
             JOIN cycles c ON c.tontine_id = t.id
             WHERE c.id = $1 AND m.user_id = $2`,
            [cycle_id, req.user.id]
        );

        if (amountRows.length === 0) {
            return apiResponse.error(res, 'Vous n\'êtes pas membre de cette tontine ou cycle invalide', 403);
        }

        const montant = amountRows[0].montant_cotisation;
        const tontine_id = amountRows[0].tontine_id;

        // Find membership_id for this user
        const { rows: membershipRows } = await pool.query(
            `SELECT id FROM memberships WHERE user_id = $1 AND tontine_id = $2`,
            [req.user.id, tontine_id]
        );
        const membership_id = membershipRows[0].id;

        /*
        TODO: V2 — Intégration API LigdiCash
        Quand l'API LigdiCash sera disponible :
        - Orange Money, Wave, MTN MoMo, Moov Money gérés automatiquement
        - Confirmation automatique via webhook
        - Plus besoin de validation manuelle par l'organisateur
        - Le montant sera débité directement depuis le téléphone du membre
        */

        // 2. Créer la cotisation
        const cotisation = await cotisationModel.create({
            cycle_id,
            membership_id,
            montant,
            nom_expediteur,
            prenom_expediteur,
            telephone_expediteur,
            moyen_paiement,
            statut: 'en_validation'
        });

        /*
        TODO: V2 — Upload capture d'écran via Firebase Storage
        Pour le MVP, preuve_url reste NULL.
        À réactiver quand Firebase Storage sera configuré.

        Logique V2 :
        1. Recevoir le fichier image dans req.file (multer)
        2. Uploader dans Firebase Storage :
           /preuves-paiement/{tontine_id}/{cotisation_id}/{timestamp}.jpg
        3. Stocker l'URL publique dans cotisations.preuve_url
        */

        // 3. Envoyer une notification à l'organisateur
        const { rows: organizers } = await pool.query(
            `SELECT user_id FROM memberships WHERE tontine_id = $1 AND role = 'organisateur'`,
            [tontine_id]
        );

        for (const org of organizers) {
            await notificationModel.create({
                user_id: org.user_id,
                type: 'paiement_soumis',
                titre: 'Nouvelle cotisation à valider',
                message: `${req.user.nom} ${req.user.prenom} a soumis sa cotisation de ${montant} FCFA\nEnvoi depuis le ${telephone_expediteur} au nom de ${nom_expediteur} ${prenom_expediteur} via ${moyen_paiement}`,
                data: { cotisation_id: cotisation.id, tontine_id }
            });
        }

        logger.info(`Paiement manuel initié par ${req.user.telephone} (${req.user.nom}) pour le cycle ${cycle_id}`);
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
