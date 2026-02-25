CREATE TABLE IF NOT EXISTS tontines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom VARCHAR(255) NOT NULL,
    description TEXT,
    montant_cotisation DECIMAL(12,2) NOT NULL CHECK (montant_cotisation > 0),
    frequence VARCHAR(20) NOT NULL
        CHECK (frequence IN ('hebdomadaire', 'bimensuelle', 'mensuelle')),
    nombre_membres_max INTEGER NOT NULL CHECK (nombre_membres_max > 1),
    date_debut DATE,
    statut VARCHAR(20) DEFAULT 'en_attente'
        CHECK (statut IN ('en_attente', 'active', 'suspendue', 'cloturee')),
    penalites_activees BOOLEAN DEFAULT false,
    montant_penalite DECIMAL(12,2) DEFAULT 0,
    code_invitation VARCHAR(20) UNIQUE,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    date_creation TIMESTAMP DEFAULT NOW(),
    date_modification TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_tontines_statut ON tontines(statut);
CREATE INDEX IF NOT EXISTS idx_tontines_code ON tontines(code_invitation);
CREATE INDEX IF NOT EXISTS idx_tontines_created_by ON tontines(created_by);
