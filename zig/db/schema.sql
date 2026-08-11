CREATE TABLE IF NOT EXISTS pets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    species TEXT NOT NULL,
    breed TEXT NOT NULL,
    age INTEGER NOT NULL,
    gender TEXT NOT NULL,
    size TEXT NOT NULL,
    description TEXT NOT NULL,
    image_url TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Available',
    location TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS adoptions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pet_id INTEGER NOT NULL,
    applicant_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    housing_type TEXT NOT NULL,
    has_yard INTEGER NOT NULL DEFAULT 0,
    other_pets TEXT NOT NULL,
    experience TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Submitted',
    notes TEXT DEFAULT '',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pet_id) REFERENCES pets(id)
);
