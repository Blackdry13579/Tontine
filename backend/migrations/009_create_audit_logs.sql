CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    tontine_id UUID REFERENCES tontines(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    details JSONB,
    ip_address VARCHAR(45),
    date_creation TIMESTAMP DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_audit_user ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_tontine ON audit_logs(tontine_id);
CREATE INDEX IF NOT EXISTS idx_audit_action ON audit_logs(action);
