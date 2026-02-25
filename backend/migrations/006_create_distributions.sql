CREATE TABLE IF NOT EXISTS distributions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cycle_id UUID REFERENCES cycles(id) ON DELETE CASCADE,
    membership_id UUID REFERENCES memberships(id) ON DELETE CASCADE,
    montant DECIMAL(12,2) NOT NULL,
    statut VARCHAR(20) DEFAULT 'planifiee'
        CHECK (statut IN ('planifiee', 'en_cours', 'effectuee', 'annulee')),
    moyen_distribution VARCHAR(50),
    reference_transaction VARCHAR(255),
    date_distribution TIMESTAMP,
    date_creation TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_distributions_cycle ON distributions(cycle_id);
CREATE INDEX IF NOT EXISTS idx_distributions_membership ON distributions(membership_id);
