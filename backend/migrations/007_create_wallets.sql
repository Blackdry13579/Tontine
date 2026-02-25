CREATE TABLE IF NOT EXISTS wallets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    solde DECIMAL(12,2) DEFAULT 0 CHECK (solde >= 0),
    devise VARCHAR(10) DEFAULT 'FCFA',
    date_creation TIMESTAMP DEFAULT NOW(),
    date_modification TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS wallet_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id UUID REFERENCES wallets(id) ON DELETE CASCADE,
    type VARCHAR(20) CHECK (type IN ('credit', 'debit')),
    montant DECIMAL(12,2) NOT NULL,
    solde_avant DECIMAL(12,2),
    solde_apres DECIMAL(12,2),
    description TEXT,
    reference VARCHAR(255),
    date_creation TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_wallet_user ON wallets(user_id);
CREATE INDEX IF NOT EXISTS idx_wallet_tx ON wallet_transactions(wallet_id);
