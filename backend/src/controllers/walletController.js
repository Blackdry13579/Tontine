const walletModel = require('../models/walletModel');
const { success, error } = require('../utils/apiResponse');
const logger = require('../utils/logger');

/*
NOTE : Ce controller affiche l'historique visuel des cotisations.
Ce n'est PAS un vrai compte bancaire.

TODO V2 : Ajouter recharge et transfert via API LigdiCash.
Code original automatique commenté ci-dessous.
*/

async function getHistorique(req, res, next) {
    try {
        const { rows: historique } = await walletModel.getHistoriqueMembre(req.user.id);
        const { rows: [resume] } = await walletModel.getResumeFinancierMembre(req.user.id);
        return success(res, {
            resume: {
                total_valide: resume.total_valide,
                total_en_attente: resume.total_en_attente,
                nombre_paiements: resume.nombre_paiements,
                nombre_retards: resume.nombre_retards,
                devise: 'FCFA'
            },
            historique
        }, 'Historique des cotisations');
    } catch (err) {
        logger.error('Erreur getHistorique wallet', { error: err.message });
        next(err);
    }
}

/*
TODO V2 — Fonctions désactivées pour le MVP
À réactiver avec l'API LigdiCash

async function recharger(req, res) { ... }
async function transferer(req, res) { ... }
*/

module.exports = { getHistorique };
