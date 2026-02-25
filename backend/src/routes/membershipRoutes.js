const express = require('express');
const router = express.Router();
const membershipController = require('../controllers/membershipController');
const auth = require('../middleware/auth');
const checkRole = require('../middleware/checkRole');
const validate = require('../middleware/validate');
const Joi = require('joi');

const joinSchema = Joi.object({
    code: Joi.string().required()
});

const orderSchema = Joi.object({
    orders: Joi.array().items(
        Joi.object({
            membership_id: Joi.string().uuid().required(),
            position_ordre: Joi.number().integer().required()
        })
    ).required()
});

router.post('/rejoindre', auth, validate(joinSchema), membershipController.joinByCode);
router.get('/tontine/:id', auth, membershipController.getMembers);
router.put('/tontine/:id/ordre', auth, checkRole('organisateur', 'admin'), validate(orderSchema), membershipController.updateOrder);
router.post('/tontine/:id/tirage', auth, checkRole('organisateur', 'admin'), membershipController.runTirage);
router.delete('/:id', auth, membershipController.deleteMembership);

module.exports = router;
