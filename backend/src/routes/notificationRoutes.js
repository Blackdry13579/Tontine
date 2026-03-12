const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const auth = require('../middleware/auth');
const checkRole = require('../middleware/checkRole');
const validate = require('../middleware/validate');
const Joi = require('joi');

const settingsSchema = Joi.object({
    jours_avant: Joi.array().items(Joi.number().integer()),
    heure_rappel: Joi.string().regex(/^([01]\d|2[0-3]):?([0-5]\d)$/),
    push_active: Joi.boolean(),
    sms_active: Joi.boolean()
});

router.get('/', auth, notificationController.getNotifications);
router.put('/tout-lire', auth, notificationController.markAllRead);
router.put('/:id/lire', auth, notificationController.markRead);
router.put('/:id/lue', auth, notificationController.markRead);
router.get('/settings', auth, notificationController.getSettings);
router.put('/settings', auth, validate(settingsSchema), notificationController.updateSettings);
router.post('/tontine/:id/rappeler-tous', auth, checkRole('organisateur', 'admin'), notificationController.remindAll);

module.exports = router;
