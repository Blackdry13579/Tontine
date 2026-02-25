const express = require('express');
const router = express.Router();
const tontineController = require('../controllers/tontineController');
const auth = require('../middleware/auth');
const checkRole = require('../middleware/checkRole');
const validate = require('../middleware/validate');
const Joi = require('joi');

// Validation schemas
const createTontineSchema = Joi.object({
    nom: Joi.string().required(),
    description: Joi.string(),
    montant_cotisation: Joi.number().positive().required(),
    frequence: Joi.string().valid('hebdomadaire', 'bimensuelle', 'mensuelle').required(),
    nombre_membres_max: Joi.number().integer().min(2).required(),
    date_debut: Joi.date(),
    penalites_activees: Joi.boolean(),
    montant_penalite: Joi.number().min(0)
});

const updateTontineSchema = Joi.object({
    nom: Joi.string(),
    description: Joi.string(),
    montant_cotisation: Joi.number().positive(),
    frequence: Joi.string().valid('hebdomadaire', 'bimensuelle', 'mensuelle'),
    nombre_membres_max: Joi.number().integer().min(2),
    date_debut: Joi.date(),
    penalites_activees: Joi.boolean(),
    montant_penalite: Joi.number().min(0)
});

const statutSchema = Joi.object({
    statut: Joi.string().valid('en_attente', 'active', 'suspendue', 'cloturee').required()
});

/**
 * @swagger
 * /tontines:
 *   post:
 *     summary: Creer une nouvelle tontine
 *     tags: [Tontines]
 *     security:
 *       - FirebaseAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/TontineInput'
 */
router.post('/', auth, validate(createTontineSchema), tontineController.createTontine);

/**
 * @swagger
 * /tontines:
 *   get:
 *     summary: Mes tontines
 *     tags: [Tontines]
 *     security:
 *       - FirebaseAuth: []
 */
router.get('/', auth, tontineController.getTontines);

/**
 * @swagger
 * /tontines/{id}:
 *   get:
 *     summary: Detail tontine
 *     tags: [Tontines]
 *     security:
 *       - FirebaseAuth: []
 */
router.get('/:id', auth, tontineController.getTontineById);

/**
 * @swagger
 * /tontines/{id}:
 *   put:
 *     summary: Modifier tontine
 *     tags: [Tontines]
 *     security:
 *       - FirebaseAuth: []
 */
router.put('/:id', auth, checkRole('organisateur', 'admin'), validate(updateTontineSchema), tontineController.updateTontine);

/**
 * @swagger
 * /tontines/{id}/statut:
 *   patch:
 *     summary: Changer statut tontine
 *     tags: [Tontines]
 *     security:
 *       - FirebaseAuth: []
 */
router.patch('/:id/statut', auth, checkRole('organisateur', 'admin'), validate(statutSchema), tontineController.updateStatut);

/**
 * @swagger
 * /tontines/{id}/invitation:
 *   get:
 *     summary: Obtenir code invitation
 *     tags: [Tontines]
 *     security:
 *       - FirebaseAuth: []
 */
router.get('/:id/invitation', auth, checkRole('organisateur', 'admin'), tontineController.getInvitation);

module.exports = router;
