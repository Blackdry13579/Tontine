CREATE TABLE IF NOT EXISTS reminder_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    jours_avant INTEGER[] DEFAULT '{1}',
    heure_rappel TIME DEFAULT '09:00',
    push_active BOOLEAN DEFAULT true,
    sms_active BOOLEAN DEFAULT false,
    date_modification TIMESTAMP DEFAULT NOW()
);
