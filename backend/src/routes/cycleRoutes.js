const express = require('express');
const router = express.Router();
const cycleController = require('../controllers/cycleController');
const auth = require('../middleware/auth');
const checkRole = require('../middleware/checkRole');
const validate = require('../middleware/validate');
const Joi = require('joi');

const createCycleSchema = Joi.object({
    date_debut: Joi.date().required(),
    date_fin: Joi.date().required()
});

router.post('/tontine/:id', auth, checkRole('organisateur', 'admin'), validate(createCycleSchema), cycleController.createCycle);
router.get('/tontine/:id', auth, cycleController.getCycles);
router.get('/:id', auth, cycleController.getCycleById);

module.exports = router;
