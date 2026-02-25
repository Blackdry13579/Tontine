require('dotenv').config();
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const pool = new Pool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
});

async function run() {
    const files = fs.readdirSync(__dirname)
        .filter(f => f.endsWith('.sql'))
        .sort();

    console.log(`Execution de ${files.length} migrations...`);

    for (const file of files) {
        try {
            const sql = fs.readFileSync(path.join(__dirname, file), 'utf8');
            await pool.query(sql);
            console.log(`OK : ${file}`);
        } catch (err) {
            console.error(`ERREUR dans ${file} : ${err.message}`);
            process.exit(1);
        }
    }

    console.log('Toutes les migrations executees !');
    await pool.end();
}

run();
