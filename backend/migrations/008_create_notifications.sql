CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    titre VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSONB,
    est_lue BOOLEAN DEFAULT false,
    date_creation TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_notif_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notif_lue ON notifications(est_lue);
