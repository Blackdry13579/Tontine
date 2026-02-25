const Joi = require('joi');
const apiResponse = require('../utils/apiResponse');

const validate = (schema) => {
    return (req, res, next) => {
        const { error } = schema.validate(req.body);
        if (error) {
            return apiResponse.error(res, error.details[0].message, 400);
        }
        next();
    };
};

module.exports = validate;
