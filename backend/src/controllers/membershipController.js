const membershipModel = require('../models/membershipModel');
const tontineModel = require('../models/tontineModel');
const pool = require('../config/database');
const apiResponse = require('../utils/apiResponse');

const joinByCode = async (req, res, next) => {
    try {
        const { code } = req.body;

        // Find tontine by code
        const { rows } = await pool.query('SELECT * FROM tontines WHERE code_invitation = $1 AND statut = $2', [code, 'en_attente']);
        if (rows.length === 0) return apiResponse.error(res, 'Code invalide ou tontine deja active', 404);

        const tontine = rows[0];

        // Check if seats available
        const members = await membershipModel.findByTontineId(tontine.id);
        if (members.length >= tontine.nombre_membres_max) {
            return apiResponse.error(res, 'Tontine complete', 400);
        }

        // Check if already member
        const existing = await membershipModel.findByUserAndTontine(req.user.id, tontine.id);
        if (existing) return apiResponse.error(res, 'Vous etes deja membre', 400);

        const membership = await membershipModel.create({
            tontine_id: tontine.id,
            user_id: req.user.id,
            role: 'membre'
        });

        return apiResponse.success(res, membership, 'Vous avez rejoint la tontine', 201);
    } catch (err) {
        next(err);
    }
};

const getMembers = async (req, res, next) => {
    try {
        const members = await membershipModel.findByTontineId(req.params.id);
        return apiResponse.success(res, members);
    } catch (err) {
        next(err);
    }
};

const updateOrder = async (req, res, next) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        const { orders } = req.body; // Array of { membership_id, position_ordre }

        for (const item of orders) {
            await client.query(
                'UPDATE memberships SET position_ordre = $1 WHERE id = $2',
                [item.position_ordre, item.membership_id]
            );
        }

        await client.query('COMMIT');
        return apiResponse.success(res, null, 'Ordre des membres mis a jour');
    } catch (err) {
        await client.query('ROLLBACK');
        next(err);
    } finally {
        client.release();
    }
};

const runTirage = async (req, res, next) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');

        const members = await membershipModel.findByTontineId(req.params.id);
        const shuffled = members.sort(() => Math.random() - 0.5);

        for (let i = 0; i < shuffled.length; i++) {
            await client.query(
                'UPDATE memberships SET position_ordre = $1 WHERE id = $2',
                [i + 1, shuffled[i].id]
            );
        }

        await client.query('COMMIT');
        return apiResponse.success(res, shuffled, 'Tirage au sort effectue');
    } catch (err) {
        await client.query('ROLLBACK');
        next(err);
    } finally {
        client.release();
    }
};

const deleteMembership = async (req, res, next) => {
    try {
        const membership = await pool.query('SELECT * FROM memberships WHERE id = $1', [req.params.id]);
        if (membership.rows.length === 0) return apiResponse.error(res, 'Membre non trouve', 404);

        const target = membership.rows[0];

        // Safety: prevent deleting the last organisateur
        if (target.role === 'organisateur') {
            // logic to check count of organisers...
        }

        await membershipModel.deleteMembership(req.params.id);
        return apiResponse.success(res, null, 'Membre retire');
    } catch (err) {
        next(err);
    }
};

module.exports = {
    joinByCode,
    getMembers,
    updateOrder,
    runTirage,
    deleteMembership
};
