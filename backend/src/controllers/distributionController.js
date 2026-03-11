const distributionModel = require('../models/distributionModel');
const cycleModel = require('../models/cycleModel');
const apiResponse = require('../utils/apiResponse');
const pool = require('../config/database');

const notificationModel = require('../models/notificationModel');
const membershipModel = require('../models/membershipModel');

const triggerDistribution = async (req, res, next) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        const { cycle_id, membership_id, montant, moyen_distribution, reference_transaction } = req.body;

        // Create Distribution
        const distribution = await distributionModel.create({
            cycle_id,
            membership_id,
            montant,
            moyen_distribution,
            reference_transaction,
            date_distribution: new Date(),
            statut: 'effectuee'
        });

        // Update Cycle Status
        await cycleModel.update(cycle_id, { statut: 'termine' });

        // Get membership to notify user
        const membership = await membershipModel.findById(membership_id);
        if (membership) {
            await notificationModel.create({
                user_id: membership.user_id,
                type: 'gain_tontine',
                titre: 'Félicitations !',
                message: `Vous avez reçu un versement de ${montant} FCFA pour votre tontine.`,
                data: {
                    cycle_id,
                    distribution_id: distribution.id,
                    montant
                }
            });
        }

        await client.query('COMMIT');
        return apiResponse.success(res, distribution, 'Distribution effectuée avec succès', 201);
    } catch (err) {
        await client.query('ROLLBACK');
        next(err);
    } finally {
        client.release();
    }
};

const getCycleDistributions = async (req, res, next) => {
    try {
        const distributions = await distributionModel.findByCycleId(req.params.id);
        return apiResponse.success(res, distributions);
    } catch (err) {
        next(err);
    }
};

const getDistributionById = async (req, res, next) => {
    try {
        const distribution = await distributionModel.findById(req.params.id);
        if (!distribution) return apiResponse.error(res, 'Distribution non trouvee', 404);
        return apiResponse.success(res, distribution);
    } catch (err) {
        next(err);
    }
};

module.exports = {
    triggerDistribution,
    getCycleDistributions,
    getDistributionById
};
