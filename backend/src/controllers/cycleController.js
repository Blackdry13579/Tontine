const cycleModel = require('../models/cycleModel');
const tontineModel = require('../models/tontineModel');
const pool = require('../config/database');
const apiResponse = require('../utils/apiResponse');

const createCycle = async (req, res, next) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        const { date_debut, date_fin } = req.body;
        const tontineId = req.params.id;

        // Get last cycle number
        const lastCycles = await cycleModel.findByTontineId(tontineId);
        const numero_cycle = lastCycles.length > 0 ? lastCycles[0].numero_cycle + 1 : 1;

        const cycle = await cycleModel.create({
            tontine_id: tontineId,
            numero_cycle,
            date_debut,
            date_fin
        });

        // Optionnel: Creer automatiquement les cotisations "en attente" pour ce cycle
        // ...

        await client.query('COMMIT');
        return apiResponse.success(res, cycle, 'Cycle cree avec succes', 201);
    } catch (err) {
        await client.query('ROLLBACK');
        next(err);
    } finally {
        client.release();
    }
};

const getCycles = async (req, res, next) => {
    try {
        const cycles = await cycleModel.findByTontineId(req.params.id);
        return apiResponse.success(res, cycles);
    } catch (err) {
        next(err);
    }
};

const getCycleById = async (req, res, next) => {
    try {
        const cycle = await cycleModel.findById(req.params.id);
        if (!cycle) return apiResponse.error(res, 'Cycle non trouve', 404);
        return apiResponse.success(res, cycle);
    } catch (err) {
        next(err);
    }
};

module.exports = {
    createCycle,
    getCycles,
    getCycleById
};
