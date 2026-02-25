const notificationModel = require('../models/notificationModel');
const membershipModel = require('../models/membershipModel');
const apiResponse = require('../utils/apiResponse');

const getNotifications = async (req, res, next) => {
    try {
        const notifications = await notificationModel.findByUserId(req.user.id);
        return apiResponse.success(res, notifications);
    } catch (err) {
        next(err);
    }
};

const markRead = async (req, res, next) => {
    try {
        const notif = await notificationModel.markAsRead(req.params.id, req.user.id);
        return apiResponse.success(res, notif, 'Notification lue');
    } catch (err) {
        next(err);
    }
};

const markAllRead = async (req, res, next) => {
    try {
        await notificationModel.markAllAsRead(req.user.id);
        return apiResponse.success(res, null, 'Toutes les notifications lues');
    } catch (err) {
        next(err);
    }
};

const getSettings = async (req, res, next) => {
    try {
        let settings = await notificationModel.getReminderSettings(req.user.id);
        if (!settings) {
            settings = await notificationModel.updateReminderSettings(req.user.id, {
                jours_avant: [1],
                heure_rappel: '09:00',
                push_active: true,
                sms_active: false
            });
        }
        return apiResponse.success(res, settings);
    } catch (err) {
        next(err);
    }
};

const updateSettings = async (req, res, next) => {
    try {
        const settings = await notificationModel.updateReminderSettings(req.user.id, req.body);
        return apiResponse.success(res, settings, 'Parametres rappels mis a jour');
    } catch (err) {
        next(err);
    }
};

const remindAll = async (req, res, next) => {
    try {
        const members = await membershipModel.findByTontineId(req.params.id);

        // Logic to send push/sms to each member...
        // For now, just create DB notifications
        for (const member of members) {
            if (member.user_id !== req.user.id) {
                await notificationModel.create({
                    user_id: member.user_id,
                    type: 'rappel_organisateur',
                    titre: 'Rappel de cotisation',
                    message: `L'organisateur vous rappelle votre cotisation.`,
                    data: { tontine_id: req.params.id }
                });
            }
        }

        return apiResponse.success(res, null, 'Rappel envoye a tous les membres');
    } catch (err) {
        next(err);
    }
};

module.exports = {
    getNotifications,
    markRead,
    markAllRead,
    getSettings,
    updateSettings,
    remindAll
};
