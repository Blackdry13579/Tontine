const express = require('express');
const router = express.Router();
const distributionController = require('../controllers/distributionController');
const auth = require('../middleware/auth');
const checkRole = require('../middleware/checkRole');
const validate = require('../middleware/validate');
const Joi = require('joi');

const distributionSchema = Joi.object({
    cycle_id: Joi.string().uuid().required(),
    membership_id: Joi.string().uuid().required(),
    montant: Joi.number().positive().required(),
    moyen_distribution: Joi.string().required(),
    reference_transaction: Joi.string()
});

router.post('/', auth, checkRole('organisateur', 'admin'), validate(distributionSchema), distributionController.triggerDistribution);
router.get('/cycle/:id', auth, distributionController.getCycleDistributions);
router.get('/:id', auth, distributionController.getDistributionById);

module.exports = router;
