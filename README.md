# 🌕 AURUM — Gestion de Tontines Numériques Premium

![Banner](https://img.shields.io/badge/AURUM-Tontine_Management-gold?style=for-the-badge)
![Tech Stack](https://img.shields.io/badge/Stack-Node.js_|_PostgreSQL_|_Flutter-blue?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-MVP_Ready-green?style=for-the-badge)

AURUM est une plateforme haut de gamme de gestion de tontines numériques (épargne collective rotative). Elle allie une esthétique "Aurum Luxe" (Émeraude & Or) à une robustesse technique pour une gestion sécurisée et fluide des cycles de tontine.

---

## 💎 Design & Esthétique
Le projet arbore une identité visuelle forte appelée **Aurum Aurum (Prestige)** :
- **Palette de couleurs** : Vert Émeraude Profond (`#1B5E20`), Or Royal (`#C9A326`) et Crème Soyeux (`#F5F0E1`).
- **UI Premium** : Interfaces inspirées du luxe, avec des ombres douces, des arrondis généreux et des micro-animations.
- **Accessibilité** : Police *Space Grotesk* pour une lisibilité moderne et élégante.

---

## 🚀 Fonctionnalités Clés (MVP)

### 👥 Utilisateurs & Profils (Refonte Fidèle)
- **Authentification Sécurisée** : Connexion par numéro de téléphone avec validation OTP (simulée pour le MVP).
- **Profil Utilisateur** : Modification complète du profil (nom, prénom, adresse) via l'API `updateProfile`.
- **Centre de Sécurité** : Gestion visuelle du code PIN et de la biométrie (V2 pour la logique backend).
- **Centre d'Aide** : Accès aux guides, FAQ et support direct depuis l'application.

### 💰 Gestion des Tontines
- **Création & Paramétrage** : Définition du cycle (hebdomadaire/mensuel), montant et membres.
- **Flux de Paiement Validé** : Soumission des preuves de cotisation et validation par l'organisateur.
- **Tirage au Sort** : Attribution automatique des rangs de gain.

### 💸 Dashboard & Wallet
- **Portefeuille Numérique** : Suivi du solde et historique des transactions.
- **Suivi Admin** : Tableau de bord pour les organisateurs (suivi des membres en retard, validations en attente).

---

## 🛠️ Stack Technique

- **Backend** : [Node.js](https://nodejs.org/) + [Express.js](https://expressjs.com/)
- **Base de Données** : [PostgreSQL](https://www.postgresql.org/) (Pur SQL, performance optimisée)
- **Mobile** : [Flutter](https://flutter.dev/) (Material 3 avec thémisation personnalisée)
- **État & Provider** : Gestion du state via `Provider` pour une réactivité optimale.

---

## 📂 Structure du Projet

```text
aurum/
├── backend/            # API REST (Node.js/Express)
│   ├── src/            # Controllers, Models, Routes
│   └── migrations/     # Evolution SQL schémas
├── mobile/             # Application Flutter
│   └── lib/            # Code source (Features, Theme, Providers)
└── pages_a_completer/  # Maquettes HTML & Ressources UI
```

---

## ⚙️ Installation

### Backend
```bash
cd backend && npm install
# Configurer .env
npm run dev
```

### Mobile
```bash
cd mobile && flutter pub get
flutter run -d chrome --web-port 8083 # Pour tester sur le port validé
```

---

## 📄 Licence
Développé par **Aurum Team**.
**MVP Validé ✅ - Prochaine étape : Backend Security V2 & Notifications Push.**
