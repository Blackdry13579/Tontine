const swaggerJsdoc = require('swagger-jsdoc');

module.exports = swaggerJsdoc({
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'AURUM Tontine API',
            version: '1.0.0',
            description: 'API REST pour la gestion de tontines numeriques AURUM',
        },
        servers: [{ url: 'http://localhost:3000/api' }],
        components: {
            securitySchemes: {
                FirebaseAuth: {
                    type: 'http',
                    scheme: 'bearer',
                    bearerFormat: 'Firebase JWT',
                    description: 'Token Firebase obtenu apres connexion',
                },
            },
            schemas: {
                TontineInput: {
                    type: 'object',
                    required: ['nom', 'montant_cotisation', 'frequence', 'nombre_membres_max'],
                    properties: {
                        nom: { type: 'string', example: 'Ma Tontine de Vacances' },
                        description: { type: 'string', example: 'Epargne collective pour Noel' },
                        montant_cotisation: { type: 'number', example: 10000 },
                        frequence: { type: 'string', enum: ['hebdomadaire', 'bimensuelle', 'mensuelle'] },
                        nombre_membres_max: { type: 'integer', example: 10 },
                        date_debut: { type: 'string', format: 'date' },
                        penalites_activees: { type: 'boolean', default: false },
                        montant_penalite: { type: 'number', default: 0 }
                    }
                },
                User: {
                    type: 'object',
                    properties: {
                        id: { type: 'string', format: 'uuid' },
                        telephone: { type: 'string' },
                        nom: { type: 'string' },
                        prenom: { type: 'string' },
                        role_systeme: { type: 'string' }
                    }
                }
            }
        },
        security: [{ FirebaseAuth: [] }],
    },
    apis: ['./src/routes/*.js'],
});
