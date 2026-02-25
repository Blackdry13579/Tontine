const success = (res, data = null, message = 'Succes', statusCode = 200) => {
    return res.status(statusCode).json({
        success: true,
        message,
        data,
        timestamp: new Date().toISOString(),
    });
};

const error = (res, message = 'Erreur serveur', statusCode = 500, errors = null) => {
    return res.status(statusCode).json({
        success: false,
        message,
        errors,
        timestamp: new Date().toISOString(),
    });
};

module.exports = { success, error };
