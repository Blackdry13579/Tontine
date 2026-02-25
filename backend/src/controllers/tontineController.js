const tontineModel = require('../models/tontineModel');
const membershipModel = require('../models/membershipModel');
const apiResponse = require('../utils/apiResponse');
const { v4: uuidv4 } = require('uuid');
const pool = require('../config/database');

const createTontine = async (req, res, next) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        const tontineData = {
            ...req.body,
            created_by: req.user.id,
            code_invitation: uuidv4().substring(0, 8).toUpperCase()
        };

        const tontine = await tontineModel.create(tontineData);

        // Create membership for the creator as 'organisateur'
        await client.query(
            'INSERT INTO memberships (tontine_id, user_id, role) VALUES ($1, $2, $3)',
            [tontine.id, req.user.id, 'organisateur']
        );

        await client.query('COMMIT');
        return apiResponse.success(res, tontine, 'Tontine creee avec succes', 201);
    } catch (err) {
        await client.query('ROLLBACK');
        next(err);
    } finally {
        client.release();
    }
};

const getTontines = async (req, res, next) => {
    try {
        const tontines = await tontineModel.findAll({
            userId: req.user.id,
            statut: req.query.statut
        });
        return apiResponse.success(res, tontines);
    } catch (err) {
        next(err);
    }
};

const getTontineById = async (req, res, next) => {
    try {
        const tontine = await tontineModel.findById(req.params.id, req.user.id);
        if (!tontine) return apiResponse.error(res, 'Tontine non trouvee', 404);

        // DRY Principle: Adapt data based on role
        if (tontine.user_role !== 'organisateur') {
            delete tontine.code_invitation; // Members don't see the code? (Or maybe they do, depends on requirements)
        }

        return apiResponse.success(res, tontine);
    } catch (err) {
        next(err);
    }
};

const updateTontine = async (req, res, next) => {
    try {
        const tontine = await tontineModel.update(req.params.id, req.body);
        return apiResponse.success(res, tontine, 'Tontine mise a jour');
    } catch (err) {
        next(err);
    }
};

const updateStatut = async (req, res, next) => {
    try {
        const { statut } = req.body;
        const tontine = await tontineModel.update(req.params.id, { statut });
        return apiResponse.success(res, tontine, `Statut tontine change en ${statut}`);
    } catch (err) {
        next(err);
    }
};

const getInvitation = async (req, res, next) => {
    try {
        const tontine = await tontineModel.findById(req.params.id, req.user.id);
        if (!tontine) return apiResponse.error(res, 'Tontine non trouvee', 404);

        let code = tontine.code_invitation;
        if (req.query.regen === 'true') {
            code = uuidv4().substring(0, 8).toUpperCase();
            await tontineModel.update(req.params.id, { code_invitation: code });
        }

        return apiResponse.success(res, { code_invitation: code });
    } catch (err) {
        next(err);
    }
};

module.exports = {
    createTontine,
    getTontines,
    getTontineById,
    updateTontine,
    updateStatut,
    getInvitation
};
