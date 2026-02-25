const router = require('express').Router();
const auth = require('../middleware/auth');
const { getHistorique } = require('../controllers/walletController');

/**
 * @swagger
 * /wallet:
 *   get:
 *     summary: Historique visuel des cotisations (dashboard membre)
 *     tags: [Wallet]
 *     security:
 *       - FirebaseAuth: []
 *     responses:
 *       200:
 *         description: Résumé financier et liste des cotisations
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 resume:
 *                   type: object
 *                   properties:
 *                     total_valide:
 *                       type: number
 *                       example: 75000
 *                     total_en_attente:
 *                       type: number
 *                       example: 25000
 *                     nombre_paiements:
 *                       type: integer
 *                     devise:
 *                       type: string
 *                       example: FCFA
 *                 historique:
 *                   type: array
 */
router.get('/', auth, getHistorique);

/*
TODO V2 — Routes désactivées pour le MVP
À réactiver avec l'API LigdiCash

router.post('/recharger', auth, recharger);
router.post('/transferer', auth, transferer);
*/

module.exports = router;
