const { error } = require('../utils/apiResponse');

module.exports = (...roles) => {
    return (req, res, next) => {
        if (!roles.includes(req.user?.role_systeme)) {
            return error(res, `Acces refuse. Role requis : ${roles.join(' ou ')}`, 403);
        }
        next();
    };
};
