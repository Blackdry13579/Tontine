const logger = require('../utils/logger');
const { error } = require('../utils/apiResponse');

module.exports = (err, req, res, next) => {
    logger.error(err.message, {
        stack: err.stack,
        url: req.url,
        method: req.method,
    });
    return error(res, err.message || 'Erreur serveur interne', err.status || 500);
};
