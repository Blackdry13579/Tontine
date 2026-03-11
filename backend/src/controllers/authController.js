const userModel = require('../models/userModel');
const apiResponse = require('../utils/apiResponse');
const logger = require('../utils/logger');

const register = async (req, res, next) => {
    try {
        const { telephone, nom, prenom, email, photo_url } = req.body;
        const firebase_uid = req.user_firebase?.uid || req.user?.firebase_uid; // Depends on auth middleware usage during registration

        // Double check if user exists
        let user = await userModel.findByFirebaseUid(firebase_uid);
        if (user) {
            return apiResponse.error(res, 'Utilisateur existe deja', 400);
        }

        user = await userModel.create({
            firebase_uid,
            telephone,
            nom,
            prenom,
            email,
            photo_url,
            profil_complet: false
        });

        logger.info(`Nouvel utilisateur inscrit: ${user.telephone}`);
        return apiResponse.success(res, {
            id: user.id,
            telephone: user.telephone,
            firebase_uid: user.firebase_uid,
            profil_complet: false,
            role_systeme: user.role_systeme
        }, 'Inscription réussie — complétez votre profil', 201);
    } catch (err) {
        next(err);
    }
};

const getMe = async (req, res, next) => {
    try {
        return apiResponse.success(res, req.user);
    } catch (err) {
        next(err);
    }
};

const updateMe = async (req, res, next) => {
    try {
        const user = await userModel.update(req.user.id, req.body);

        if (!user) return apiResponse.error(res, 'Erreur lors de la mise à jour', 500);

        return apiResponse.success(res, user, 'Profil mis a jour');
    } catch (err) {
        next(err);
    }
};

module.exports = {
    register,
    getMe,
    updateMe,
};
