const distributionModel = require('../models/distributionModel');
const cycleModel = require('../models/cycleModel');
const apiResponse = require('../utils/apiResponse');
const pool = require('../config/database');

const triggerDistribution = async (req, res, next) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        const { cycle_id, membership_id, montant, moyen_distribution, reference_transaction } = req.body;

        // Check if cycle is closed or ready for distribution?
        // Logic here...

        const distribution = await distributionModel.create({
            cycle_id,
            membership_id,
            montant,
            moyen_distribution,
            reference_transaction,
            date_distribution: new Date(),
            statut: 'effectuee'
        });

        await client.query('COMMIT');
        return apiResponse.success(res, distribution, 'Distribution effectuee avec succes', 201);
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
