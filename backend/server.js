require('dotenv').config();
const app = require('./src/app');
const logger = require('./src/utils/logger');
const pool = require('./src/config/database');

const PORT = process.env.PORT || 3000;

async function start() {
    try {
        // Verifier la connexion DB avant de demarrer
        await pool.query('SELECT NOW()');
        logger.info('Connexion PostgreSQL etablie');

        app.listen(PORT, () => {
            logger.info(`Serveur AURUM demarre sur le port ${PORT}`);
            logger.info(`API     : http://localhost:${PORT}/api`);
            logger.info(`Swagger : http://localhost:${PORT}/api-docs`);
            logger.info(`Health  : http://localhost:${PORT}/health`);
        });
    } catch (err) {
        logger.error('Erreur au demarrage du serveur :', err);
        process.exit(1);
    }
}

start();
