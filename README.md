# 🌕 AURUM — Gestion de Tontines Numériques

![Banner](https://img.shields.io/badge/AURUM-Tontine_Management-gold?style=for-the-badge)
![Tech Stack](https://img.shields.io/badge/Stack-Node.js_|_PostgreSQL_|_Flutter-blue?style=for-the-badge)

AURUM est une plateforme moderne de gestion de tontines numériques (épargne collective rotative). Elle facilite la création, le suivi des cotisations et la distribution équitable des fonds, le tout sécurisé par une authentification forte et une architecture robuste.

---

## 🚀 Fonctionnalités Clés

### 👥 Utilisateurs & Profils
- **Authentification Sécurisée** : Intégration Firebase Auth (OTP/Google).
- **Profils Complets** : Gestion des informations personnelles et rôles système.
- **Sécurité Locale** : Support du code PIN et de la biométrie (côté mobile).

### 💰 Gestion des Tontines
- **Création Intuitive** : Paramétrage du montant, de la fréquence et du nombre de membres.
- **Invitations** : Rejoindre facilement un groupe via un code unique.
- **Tirage au Sort** : Algorithme automatique pour définir l'ordre de gain des membres.

### 💸 Flux Financier (MVP)
- **Validation Manuelle** : Soumission de preuves de paiement simplifiée.
- **Dashboard Organisateur** : Vue d'ensemble des fonds collectés et validations en attente.
- **Historique Visuel** : Suivi précis de chaque cotisation et distribution.

### 🔔 Notifications & Rappels
- Alertes automatiques avant chaque échéance de cotisation.
- Notifications de validation et de gain.

---

## 🛠️ Stack Technique

- **Backend** : [Node.js](https://nodejs.org/) + [Express.js](https://expressjs.com/)
- **Base de Données** : [PostgreSQL](https://www.postgresql.org/) (SQL pur, sans ORM pour une performance maximale)
- **Mobile** : [Flutter](https://flutter.dev/) (Android/iOS)
- **Authentification** : [Firebase SDK Admin](https://firebase.google.com/docs/admin)
- **Documentation API** : [Swagger / OpenAPI 3.0](https://swagger.io/)
- **Logs** : [Winston](https://github.com/winstonjs/winston)

---

## 📂 Structure du Projet

```text
aurum/
├── backend/            # API REST (Node.js/Express)
│   ├── src/            # Code source (Controllers, Models, Middlewares)
│   ├── migrations/     # Scripts SQL versionnés
│   └── server.js       # Point d'entrée
├── mobile/             # Application Mobile (Flutter)
└── docs/               # Documentation complémentaire
```

---

## ⚙️ Installation & Lancement

### 1️⃣ Prérequis
- Node.js (v16+)
- PostgreSQL (v14+)
- Flutter SDK

### 2️⃣ Configuration Backend
```bash
cd backend
npm install
# Créez votre fichier .env basé sur .env.example
npm run migrate
npm run dev
```

### 3️⃣ Accès Rapide
- **API** : `http://localhost:3000/api`
- **Documentation Swagger** : `http://localhost:3000/api-docs`
- **Health Check** : `http://localhost:3000/health`

---

## 📄 Licence
Ce projet est développé par Aurum Team. Tous droits réservés.
