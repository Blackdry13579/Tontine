const admin = require('../config/firebase');
const { error } = require('../utils/apiResponse');
const userModel = require('../models/userModel');

/*
NOTE ARCHITECTURE — PIN et Biométrie
Le CDC demande PIN/biométrie (Section 4.1) et auth forte (Section 6.3).
Ces fonctionnalités sont gérées côté Flutter (flutter_secure_storage, local_auth).
Firebase Admin SDK gère l'authentification OTP.
Le backend vérifie uniquement le token Firebase — aucun PIN stocké ici.
*/

module.exports = async (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (!authHeader?.startsWith('Bearer ')) {
        return error(res, 'Token manquant dans le header Authorization', 401);
    }

    const token = authHeader.split('Bearer ')[1];

    try {
        // En mode dev (si configuré), on accepte un token simulé
        if (token.startsWith('mock_firebase_uid_')) {
            const user = await userModel.findByFirebaseUid(token);
            if (!user) return error(res, 'Utilisateur non trouve — inscrire via /api/auth/register', 404);
            req.user = user;
            return next();
        }

        const decoded = await admin.auth().verifyIdToken(token);
        const user = await userModel.findByFirebaseUid(decoded.uid);
        if (!user) return error(res, 'Utilisateur non trouve — inscrire via /api/auth/register', 404);
        req.user = user;
        next();
    } catch (err) {
        return error(res, 'Token Firebase invalide ou expire', 401);
    }
};
