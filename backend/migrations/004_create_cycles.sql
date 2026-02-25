CREATE TABLE IF NOT EXISTS cycles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tontine_id UUID REFERENCES tontines(id) ON DELETE CASCADE,
    numero_cycle INTEGER NOT NULL,
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    statut VARCHAR(20) DEFAULT 'en_cours'
        CHECK (statut IN ('en_cours', 'termine', 'annule')),
    montant_collecte DECIMAL(12,2) DEFAULT 0,
    date_creation TIMESTAMP DEFAULT NOW(),
    UNIQUE(tontine_id, numero_cycle)
);
CREATE INDEX IF NOT EXISTS idx_cycles_tontine ON cycles(tontine_id);
CREATE INDEX IF NOT EXISTS idx_cycles_statut ON cycles(statut);
