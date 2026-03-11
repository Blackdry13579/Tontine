const pool = require('../config/database');
const apiResponse = require('../utils/apiResponse');

module.exports = (...roles) => {
    return async (req, res, next) => {
        try {
            const userId = req.user?.id;
            const systemRole = req.user?.role_systeme;
            let targetId = req.params.id;

            // 1. Check system role (admin always passes)
            if (systemRole === 'admin' || roles.includes(systemRole)) {
                return next();
            }

            if (targetId && userId) {
                let tontineId = targetId;

                // 2. Resolve tontineId if this is a cotisation route
                if (req.baseUrl.includes('cotisations')) {
                    const cotResult = await pool.query(
                        'SELECT t.id FROM tontines t JOIN cycles c ON c.tontine_id = t.id JOIN cotisations cot ON cot.cycle_id = c.id WHERE cot.id = $1',
                        [targetId]
                    );
                    if (cotResult.rows.length > 0) {
                        tontineId = cotResult.rows[0].id;
                    }
                }
                // 3. Resolve tontineId if this is a cycle route
                else if (req.baseUrl.includes('cycles')) {
                    const cycResult = await pool.query(
                        'SELECT tontine_id FROM cycles WHERE id = $1',
                        [targetId]
                    );
                    if (cycResult.rows.length > 0) {
                        tontineId = cycResult.rows[0].tontine_id;
                    }
                }

                // 4. Check tontine role
                const result = await pool.query(
                    'SELECT role FROM memberships WHERE tontine_id = $1 AND user_id = $2',
                    [tontineId, userId]
                );

                if (result.rows.length > 0) {
                    const tontineRole = result.rows[0].role;
                    if (roles.includes(tontineRole)) {
                        return next();
                    }
                }
            }

            return apiResponse.error(res, `Acces refuse. Role requis : ${roles.join(' ou ')}`, 403);
        } catch (err) {
            next(err);
        }
    };
};
