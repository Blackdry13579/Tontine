CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    firebase_uid VARCHAR(255) UNIQUE NOT NULL,
    telephone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255),
    nom VARCHAR(100),
    prenom VARCHAR(100),
    photo_url TEXT,
    role_systeme VARCHAR(20) DEFAULT 'membre'
        CHECK (role_systeme IN ('membre', 'organisateur', 'admin')),
    est_verifie BOOLEAN DEFAULT false,
    date_creation TIMESTAMP DEFAULT NOW(),
    date_modification TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_users_firebase_uid ON users(firebase_uid);
CREATE INDEX IF NOT EXISTS idx_users_telephone ON users(telephone);
