CREATE TABLE IF NOT EXISTS cotisations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cycle_id UUID REFERENCES cycles(id) ON DELETE CASCADE,
    membership_id UUID REFERENCES memberships(id) ON DELETE CASCADE,
    montant DECIMAL(12,2) NOT NULL,
    montant_penalite DECIMAL(12,2) DEFAULT 0,
    statut VARCHAR(20) DEFAULT 'en_attente'
        CHECK (statut IN ('en_attente', 'en_validation', 'payee', 'en_retard', 'rejetee')),
    moyen_paiement VARCHAR(50),
    reference_transaction VARCHAR(255),
    preuve_paiement_url TEXT,
    date_echeance DATE,
    date_paiement TIMESTAMP,
    validated_by UUID REFERENCES users(id),
    date_validation TIMESTAMP,
    date_creation TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_cotisations_cycle ON cotisations(cycle_id);
CREATE INDEX IF NOT EXISTS idx_cotisations_membership ON cotisations(membership_id);
CREATE INDEX IF NOT EXISTS idx_cotisations_statut ON cotisations(statut);
