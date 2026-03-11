/**
 * AURUM Backend — Script de Tests Automatiques
 * Usage : node tests/run_tests.js TOKEN_FIREBASE
 */

require('dotenv').config();
const http = require('http');

const BASE_URL = 'http://localhost:3000';
const TOKEN = process.argv[2];

if (!TOKEN) {
    console.error('❌ Usage : node tests/run_tests.js TOKEN_FIREBASE');
    process.exit(1);
}

let passed = 0;
let failed = 0;
let total = 0;

const created = {
    tontineId: null,
    cycleId: null,
    cotisationId: null,
};

// ─── Helpers ────────────────────────────────────────────────────────────────

function request(method, path, body = null, token = TOKEN) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'localhost',
            port: 3000,
            path,
            method,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': token ? `Bearer ${token}` : '',
            },
        };
        const req = http.request(options, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
                catch { resolve({ status: res.statusCode, body: data }); }
            });
        });
        req.on('error', reject);
        if (body) req.write(JSON.stringify(body));
        req.end();
    });
}

function assert(name, condition, details = '') {
    total++;
    if (condition) {
        console.log(`  ✅ ${name}`);
        passed++;
    } else {
        console.log(`  ❌ ${name}${details ? ' → ' + details : ''}`);
        failed++;
    }
}

function section(name) {
    console.log(`\n${'─'.repeat(60)}`);
    console.log(`📋 ${name}`);
    console.log('─'.repeat(60));
}

// ─── Tests ──────────────────────────────────────────────────────────────────

async function testHealth() {
    section('HEALTH CHECK');
    const res = await request('GET', '/health', null, '');
    assert('GET /health → 200', res.status === 200);
    assert('GET /health → status OK', res.body?.status === 'OK');
    assert('GET /health → timestamp', !!res.body?.timestamp);
}

async function testAuth() {
    section('AUTH — Inscription et Profil');

    // Register
    const reg = await request('POST', '/api/auth/register', {
        telephone: '+22600000099',
    });
    assert('POST /register → 201', reg.status === 201);
    assert('POST /register → success true', reg.body.success === true);
    assert('POST /register → profil_complet false', reg.body.data?.profil_complet === false);
    assert('POST /register → role = membre', reg.body.data?.role_systeme === 'membre');
    assert('POST /register → firebase_uid', !!reg.body.data?.firebase_uid);
    assert('POST /register → format correct', !!reg.body.timestamp);

    // GET /me
    const me = await request('GET', '/api/auth/me');
    assert('GET /me → 200', me.status === 200);
    assert('GET /me → success true', me.body.success === true);
    assert('GET /me → a un id', !!me.body.data?.id);
    assert('GET /me → a telephone', !!me.body.data?.telephone);

    // PUT /me avec ville
    const update = await request('PUT', '/api/auth/me', {
        nom: 'Koné',
        prenom: 'Jean',
        ville: 'Abidjan',
    });
    assert('PUT /me → 200', update.status === 200);
    assert('PUT /me → profil_complet true', update.body.data?.profil_complet === true);
    assert('PUT /me → ville mise à jour', update.body.data?.ville === 'Abidjan');
    assert('PUT /me → adresse absente', update.body.data?.adresse === undefined);

    // PUT /me sans token → 401
    const noAuth = await request('PUT', '/api/auth/me', { nom: 'Test' }, '');
    assert('PUT /me sans token → 401', noAuth.status === 401);
}

async function testTontines() {
    section('TONTINES — CRUD');

    // Créer
    const create = await request('POST', '/api/tontines', {
        nom: 'Tontine Test Auto',
        description: 'Créée par le script de test',
        montant_cotisation: 25000,
        frequence: 'mensuelle',
        nombre_membres_max: 5,
        date_debut: '2026-04-01',
    });
    assert('POST /tontines → 201', create.status === 201);
    assert('POST /tontines → success true', create.body.success === true);
    assert('POST /tontines → a un id', !!create.body.data?.id);
    assert('POST /tontines → nom correct', create.body.data?.nom === 'Tontine Test Auto');
    assert('POST /tontines → format correct', !!create.body.timestamp);
    if (create.body.data?.id) created.tontineId = create.body.data.id;

    // Liste
    const list = await request('GET', '/api/tontines');
    assert('GET /tontines → 200', list.status === 200);
    assert('GET /tontines → tableau', Array.isArray(list.body.data));

    if (!created.tontineId) {
        console.log('  ⚠️  tontineId manquant — tests suivants ignorés');
        return;
    }

    // Détail
    const detail = await request('GET', `/api/tontines/${created.tontineId}`);
    assert('GET /tontines/:id → 200', detail.status === 200);
    assert('GET /tontines/:id → bon id', detail.body.data?.id === created.tontineId);

    // Modifier
    const update = await request('PUT', `/api/tontines/${created.tontineId}`, {
        description: 'Description mise à jour',
    });
    assert('PUT /tontines/:id → 200', update.status === 200);
    assert('PUT /tontines/:id → success', update.body.success === true);

    // Code invitation
    const code = await request('GET', `/api/tontines/${created.tontineId}/invitation`);
    assert('GET /tontines/:id/invitation → 200', code.status === 200);
    assert('GET /tontines/:id/invitation → code', !!code.body.data?.code_invitation);

    // Sans token
    const noAuth = await request('GET', '/api/tontines', null, '');
    assert('GET /tontines sans token → 401', noAuth.status === 401);
}

async function testMemberships() {
    section('MEMBERSHIPS');

    if (!created.tontineId) {
        console.log('  ⚠️  tontineId manquant — tests ignorés');
        return;
    }

    // Liste membres
    const members = await request('GET', `/api/memberships/tontine/${created.tontineId}`);
    assert('GET /memberships/tontine/:id → 200', members.status === 200);
    assert('GET /memberships/tontine/:id → tableau', Array.isArray(members.body.data));
}

async function testCycles() {
    section('CYCLES');

    if (!created.tontineId) {
        console.log('  ⚠️  tontineId manquant — tests ignorés');
        return;
    }

    // Créer cycle
    const create = await request('POST', `/api/cycles/tontine/${created.tontineId}`, {
        numero_cycle: 1,
        date_debut: '2026-04-01',
        date_fin: '2026-04-30',
    });
    assert('POST /cycles/tontine/:id → 201', create.status === 201);
    assert('POST /cycles/tontine/:id → success', create.body.success === true);
    if (create.body.data?.id) created.cycleId = create.body.data.id;

    // Liste cycles
    const list = await request('GET', `/api/cycles/tontine/${created.tontineId}`);
    assert('GET /cycles/tontine/:id → 200', list.status === 200);
    assert('GET /cycles/tontine/:id → tableau', Array.isArray(list.body.data));
}

async function testCotisations() {
    section('COTISATIONS — Paiement Manuel');

    if (!created.cycleId) {
        console.log('  ⚠️  cycleId manquant — tests ignorés');
        return;
    }

    // Soumettre cotisation
    const submit = await request('POST', '/api/cotisations/soumettre', {
        cycle_id: created.cycleId,
        moyen_paiement: 'orange_money',
        telephone_expediteur: '+22501111111',
        nom_expediteur: 'Aminata',
        prenom_expediteur: 'Koné',
    });
    assert('POST /cotisations/soumettre → 201',
        submit.status === 201);
    assert('POST /cotisations/soumettre → statut en_attente_validation',
        submit.body.data?.statut === 'en_attente_validation');
    assert('POST /cotisations/soumettre → montant récupéré automatiquement',
        submit.body.data?.montant === 25000);
    assert('POST /cotisations/soumettre → nom_expediteur enregistré',
        submit.body.data?.nom_expediteur === 'Aminata');
    assert('POST /cotisations/soumettre → telephone_expediteur enregistré',
        submit.body.data?.telephone_expediteur === '+22501111111');
    assert('POST /cotisations/soumettre → PAS de montant dans le body requis',
        submit.body.success === true);
    if (submit.body.data?.id) created.cotisationId = submit.body.data.id;

    // Cotisations en attente
    const pending = await request('GET', '/api/cotisations/en-attente-validation');
    assert('GET /cotisations/en-attente-validation → 200', pending.status === 200);
    assert('GET /cotisations/en-attente-validation → tableau', Array.isArray(pending.body.data));

    // Historique
    const history = await request('GET', '/api/cotisations/historique');
    assert('GET /cotisations/historique → 200', history.status === 200);
    assert('GET /cotisations/historique → tableau', Array.isArray(history.body.data));

    if (!created.cotisationId) return;

    // Valider
    const validate = await request('POST', `/api/cotisations/${created.cotisationId}/valider`);
    assert('POST /cotisations/:id/valider → 200', validate.status === 200);
    assert('POST /cotisations/:id/valider → statut validee', validate.body.data?.statut === 'validee');

    // Rejeter (nouvelle cotisation)
    const submit2 = await request('POST', '/api/cotisations/soumettre', {
        cycle_id: created.cycleId,
        moyen_paiement: 'wave',
        telephone_expediteur: '+22502222222',
        nom_expediteur: 'Moussa',
        prenom_expediteur: 'Traoré',
    });
    if (submit2.body.data?.id) {
        const reject = await request('POST', `/api/cotisations/${submit2.body.data.id}/rejeter`, {
            motif: 'Montant incorrect reçu',
        });
        assert('POST /cotisations/:id/rejeter → 200', reject.status === 200);
        assert('POST /cotisations/:id/rejeter → statut rejetee', reject.body.data?.statut === 'rejetee');
        assert('POST /cotisations/:id/rejeter → motif enregistré', !!reject.body.data?.motif_rejet);
    }
}

async function testWallet() {
    section('WALLET — Historique Visuel');

    const wallet = await request('GET', '/api/wallet');
    assert('GET /wallet → 200', wallet.status === 200);
    assert('GET /wallet → success true', wallet.body.success === true);
    assert('GET /wallet → a resume', !!wallet.body.data?.resume);
    assert('GET /wallet → total_valide présent', wallet.body.data?.resume?.total_valide !== undefined);
    assert('GET /wallet → total_en_attente', wallet.body.data?.resume?.total_en_attente !== undefined);
    assert('GET /wallet → devise = FCFA', wallet.body.data?.resume?.devise === 'FCFA');
    assert('GET /wallet → historique tableau', Array.isArray(wallet.body.data?.historique));

    // Routes V2 désactivées
    const recharge = await request('POST', '/api/wallet/recharger', { montant: 10000 });
    assert('POST /wallet/recharger désactivé (pas 200)',
        recharge.status !== 200);
}

async function testNotifications() {
    section('NOTIFICATIONS');

    const list = await request('GET', '/api/notifications');
    assert('GET /notifications → 200', list.status === 200);
    assert('GET /notifications → tableau', Array.isArray(list.body.data));

    const settings = await request('GET', '/api/notifications/settings');
    assert('GET /notifications/settings → 200', settings.status === 200);

    // Tout marquer comme lu
    const readAll = await request('PUT', '/api/notifications/tout-lire');
    assert('PUT /notifications/tout-lire → 200', readAll.status === 200);
}

async function testAdminDashboard() {
    section('ADMIN — Dashboard Tontine');

    if (!created.tontineId) {
        console.log('  ⚠️  tontineId manquant — test ignoré');
        return;
    }

    const dashboard = await request('GET', `/api/admin/tontine/${created.tontineId}/dashboard`);
    assert('GET /admin/tontine/:id/dashboard → 200',
        dashboard.status === 200);
    assert('GET /admin/tontine/:id/dashboard → total_collecte',
        dashboard.body.data?.total_collecte !== undefined);
    assert('GET /admin/tontine/:id/dashboard → devise FCFA',
        dashboard.body.data?.devise === 'FCFA');
    assert('GET /admin/tontine/:id/dashboard → cotisations_en_attente tableau',
        Array.isArray(dashboard.body.data?.cotisations_en_attente));
}

async function testSecurity() {
    section('SECURITE — Contrôle des accès');

    const protectedRoutes = [
        { method: 'GET', path: '/api/tontines' },
        { method: 'GET', path: '/api/auth/me' },
        { method: 'GET', path: '/api/wallet' },
        { method: 'GET', path: '/api/notifications' },
        { method: 'GET', path: '/api/cotisations/historique' },
    ];

    for (const route of protectedRoutes) {
        const res = await request(route.method, route.path, null, '');
        assert(`${route.method} ${route.path} sans token → 401`, res.status === 401);
    }

    // Routes publiques
    const health = await request('GET', '/health', null, '');
    assert('GET /health sans token → 200', health.status === 200);

    const swagger = await request('GET', '/api-docs/', null, '');
    assert('GET /api-docs sans token → accessible',
        [200, 301, 302].includes(swagger.status));
}

// ─── Rapport Final ───────────────────────────────────────────────────────────

function printReport() {
    console.log(`\n${'═'.repeat(60)}`);
    console.log('📊 RAPPORT FINAL DES TESTS');
    console.log('═'.repeat(60));
    console.log(`Total   : ${total}`);
    console.log(`Réussis : ${passed} ✅`);
    console.log(`Échoués : ${failed} ❌`);
    console.log(`Taux    : ${Math.round((passed / total) * 100)}%`);
    console.log('═'.repeat(60));

    if (failed === 0) {
        console.log('🎉 Tous les tests passent ! Le backend est opérationnel.');
    } else {
        console.log(`⚠️  ${failed} test(s) échoué(s) — corriger avant de continuer.`);
        process.exit(1);
    }
}

// ─── Exécution ───────────────────────────────────────────────────────────────

async function runAll() {
    console.log('🚀 AURUM Backend — Tests Automatiques');
    console.log(`📡 Serveur : ${BASE_URL}`);
    console.log(`🔑 Token   : ${TOKEN.substring(0, 20)}...`);

    try {
        await testHealth();
        await testAuth();
        await testTontines();
        await testMemberships();
        await testCycles();
        await testCotisations();
        await testWallet();
        await testNotifications();
        await testAdminDashboard();
        await testSecurity();
    } catch (err) {
        console.error('\n❌ Erreur inattendue :', err.message);
        process.exit(1);
    }

    printReport();
}

runAll();
