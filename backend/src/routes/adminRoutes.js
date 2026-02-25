const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const auth = require('../middleware/auth');
const checkRole = require('../middleware/checkRole');

/**
 * @swagger
 * /admin/dashboard:
 *   get:
 *     summary: Statistiques globales du dashboard
 *     tags: [Admin]
 *     security:
 *       - FirebaseAuth: []
 */
router.get('/dashboard', auth, adminController.getDashboardStats);

/**
 * @swagger
 * /admin/tontine/{id}/journal:
 *   get:
 *     summary: Journal d'audit d'une tontine
 *     tags: [Admin]
 *     security:
 *       - FirebaseAuth: []
 */
router.get('/tontine/:id/journal', auth, checkRole('organisateur', 'admin'), adminController.getTontineAudit);

/**
 * @swagger
 * /admin/tontine/{tontineId}/dashboard:
 *   get:
 *     summary: Dashboard admin d'une tontine (total collecté + paiements en attente)
 *     tags: [Admin]
 *     security:
 *       - FirebaseAuth: []
 */
router.get('/tontine/:tontineId/dashboard', auth, adminController.getDashboardTontine);

module.exports = router;
