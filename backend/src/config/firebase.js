const admin = require('firebase-admin');

if (!admin.apps.length) {
    const privateKey = process.env.FIREBASE_PRIVATE_KEY;
    if (privateKey && !privateKey.includes('CLE_ICI')) {
        admin.initializeApp({
            credential: admin.credential.cert({
                projectId: process.env.FIREBASE_PROJECT_ID,
                privateKey: privateKey.replace(/\\n/g, '\n'),
                clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
            }),
        });
    } else {
        console.warn('Firebase Admin SDK non initialise (CLE_ICI detectee). Les routes protegees echoueront.');
    }
}

module.exports = admin;
