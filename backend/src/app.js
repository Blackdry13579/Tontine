require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const swaggerUi = require('swagger-ui-express');
const swaggerSpec = require('./config/swagger');
const routes = require('./routes/index');
const errorHandler = require('./middleware/errorHandler');

const app = express();

// Securite et parsing
app.use(helmet());
app.use(cors({ 
    origin: process.env.NODE_ENV === 'development' ? '*' : process.env.FRONTEND_URL,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan('combined'));

// Documentation Swagger — PUBLIC, pas besoin de token
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Health check — PUBLIC, pas besoin de token
app.get('/health', (req, res) => {
    res.json({ status: 'OK', version: '1.0.0', timestamp: new Date().toISOString() });
});

// Toutes les routes API
app.use('/api', routes);

// Gestionnaire d'erreurs global — TOUJOURS EN DERNIER
app.use(errorHandler);

module.exports = app;
