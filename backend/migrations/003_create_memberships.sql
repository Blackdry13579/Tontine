CREATE TABLE IF NOT EXISTS memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tontine_id UUID REFERENCES tontines(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'membre' CHECK (role IN ('membre', 'organisateur')),
    statut VARCHAR(20) DEFAULT 'actif' CHECK (statut IN ('actif', 'suspendu', 'exclu')),
    position_ordre INTEGER,
    date_adhesion TIMESTAMP DEFAULT NOW(),
    UNIQUE(tontine_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_memberships_tontine ON memberships(tontine_id);
CREATE INDEX IF NOT EXISTS idx_memberships_user ON memberships(user_id);
