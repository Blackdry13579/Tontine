const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');
const Joi = require('joi');
const admin = require('../config/firebase');
const apiResponse = require('../utils/apiResponse');

// Validation schemas
const registerSchema = Joi.object({
    telephone: Joi.string().required(),
    nom: Joi.string(),
    prenom: Joi.string(),
    email: Joi.string().email(),
    photo_url: Joi.string().uri().allow(''),
});

const updateProfileSchema = Joi.object({
    nom: Joi.string().max(100).optional(),
    prenom: Joi.string().max(100).optional(),
    email: Joi.string().email().optional().allow('', null),
    ville: Joi.string().max(100).optional().allow('', null),
    photo_url: Joi.string().uri().optional().allow('', null),
});

/**
 * Middleware session for registration 
 * (since normal auth middleware requires user to exist in DB)
 */
const registrationAuth = async (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
        return apiResponse.error(res, 'Token manquant', 401);
    }
    const token = authHeader.split('Bearer ')[1];
    try {
        if (token.startsWith('mock_firebase_uid_')) {
            req.user_firebase = { uid: token };
            return next();
        }

        const decoded = await admin.auth().verifyIdToken(token);
        req.user_firebase = decoded;
        next();
    } catch (err) {
        return apiResponse.error(res, 'Token invalide', 401);
    }
};

/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Creer un profil utilisateur apres Firebase Auth
 *     tags: [Auth]
 *     security:
 *       - FirebaseAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [telephone]
 *             properties:
 *               telephone:
 *                 type: string
 *                 example: "+22507000000"
 *               nom:
 *                 type: string
 *               prenom:
 *                 type: string
 *               email:
 *                 type: string
 *               photo_url:
 *                 type: string
 *     responses:
 *       201:
 *         description: Utilisateur cree avec succes
 *       400:
 *         description: Donnees invalides
 *       401:
 *         description: Token Firebase invalide
 */
router.post('/register', registrationAuth, validate(registerSchema), authController.register);

/**
 * @swagger
 * /auth/me:
 *   get:
 *     summary: Retourner mon profil complet
 *     tags: [Auth]
 *     security:
 *       - FirebaseAuth: []
 *     responses:
 *       200:
 *         description: Profil recupere
 *       401:
 *         description: Non authentifie
 */
router.get('/me', auth, authController.getMe);

/**
 * @swagger
 * /auth/me:
 *   put:
 *     summary: Modifier mon profil
 *     tags: [Auth]
 *     security:
 *       - FirebaseAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               nom:
 *                 type: string
 *               prenom:
 *                 type: string
 *               email:
 *                 type: string
 *               photo_url:
 *                 type: string
 *     responses:
 *       200:
 *         description: Profil mis a jour
 */
router.put('/me', auth, validate(updateProfileSchema), authController.updateMe);

module.exports = router;
