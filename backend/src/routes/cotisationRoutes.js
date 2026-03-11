const express = require('express');
const router = express.Router();
const cotisationController = require('../controllers/cotisationController');
const auth = require('../middleware/auth');
const checkRole = require('../middleware/checkRole');
const validate = require('../middleware/validate');
const Joi = require('joi');

const soumettreSchema = Joi.object({
    cycle_id: Joi.string().uuid().required(),
    moyen_paiement: Joi.string()
        .valid('orange_money', 'wave', 'mtn_momo', 'moov_money', 'autre')
        .required(),
    telephone_expediteur: Joi.string().max(20).required(),
    nom_expediteur: Joi.string().max(100).required(),
    prenom_expediteur: Joi.string().max(100).required(),
});

const rejectSchema = Joi.object({
    motif: Joi.string().required()
});

/**
 * @swagger
 * /cotisations/soumettre:
 *   post:
 *     summary: Membre soumet une preuve de paiement manuel
 *     tags: [Cotisations]
 *     security:
 *       - FirebaseAuth: []
 */
router.post('/soumettre', auth, validate(soumettreSchema), cotisationController.initiatePayment);

/**
 * @swagger
 * /cotisations/cycle/{id}:
 *   get:
 *     summary: Liste des cotisations d'un cycle
 *     tags: [Cotisations]
 *     security:
 *       - FirebaseAuth: []
 */
router.get('/cycle/:id', auth, cotisationController.getCycleCotisations);

/**
 * @swagger
 * /cotisations/historique:
 *   get:
 *     summary: Historique personnel des cotisations
 *     tags: [Cotisations]
 *     security:
 *       - FirebaseAuth: []
 */
router.get('/historique', auth, cotisationController.getHistory);

/**
 * @swagger
 * /cotisations/en-attente-validation:
 *   get:
 *     summary: Liste des cotisations à valider (Organisateur)
 *     tags: [Cotisations]
 *     security:
 *       - FirebaseAuth: []
 */
router.get('/en-attente-validation', auth, checkRole('organisateur', 'admin'), cotisationController.getPendingValidations);

/**
 * @swagger
 * /cotisations/{id}/valider:
 *   post:
 *     summary: Valider une cotisation (Organisateur)
 *     tags: [Cotisations]
 *     security:
 *       - FirebaseAuth: []
 */
router.post('/:id/valider', auth, checkRole('organisateur', 'admin'), cotisationController.validateCotisation);

/**
 * @swagger
 * /cotisations/{id}/rejeter:
 *   post:
 *     summary: Rejeter une cotisation avec motif (Organisateur)
 *     tags: [Cotisations]
 *     security:
 *       - FirebaseAuth: []
 */
router.post('/:id/rejeter', auth, checkRole('organisateur', 'admin'), validate(rejectSchema), cotisationController.rejectCotisation);

/*
TODO V2 — Webhook paiement automatique LigdiCash
POST /api/cotisations/webhook
À réactiver quand l'API LigdiCash sera intégrée.
*/

module.exports = router;
