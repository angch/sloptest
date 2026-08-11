INSERT INTO pets (name, species, breed, age, gender, size, description, image_url, status, location) VALUES
('Luna', 'Dog', 'Golden Retriever', 8, 'Female', 'Medium', 'Luna is a joyful, gentle 8-month-old Golden Retriever puppy who loves playing fetch, swimming, and cuddling on sunny afternoons. She gets along amazingly with kids and other pets.', '/images/golden_retriever.jpg', 'Available', 'San Francisco Haven'),
('Oliver', 'Cat', 'Tabby Kitten', 5, 'Male', 'Small', 'Oliver is an adorable ginger tabby kitten with a soft purr. He spends his days chasing feather toys and curling up in cozy laps for long naps.', '/images/tabby_kitten.jpg', 'Available', 'Oakland Shelter'),
('Barnaby', 'Rabbit', 'Holland Lop', 12, 'Male', 'Small', 'Barnaby is a calm, friendly Holland Lop bunny who loves fresh carrot tops and gentle nose scratches. Litter-box trained and loves room to hop around.', '/images/lop_bunny.jpg', 'Available', 'San Jose Adoption Hub'),
('Bella', 'Dog', 'French Bulldog', 14, 'Female', 'Small', 'Bella is a sweet-natured French Bulldog with expressive eyes and a playful spirit. Ideal companion for apartment living and relaxed walks.', '/images/hero.jpg', 'Pending', 'San Francisco Haven'),
('Milo', 'Cat', 'Siamese', 24, 'Male', 'Medium', 'Milo is a vocal, highly intelligent Siamese cat who loves interactive puzzle games and perch spots by warm windows.', '/images/tabby_kitten.jpg', 'Available', 'Oakland Shelter'),
('Coco', 'Bird', 'Cockatiel', 18, 'Female', 'Small', 'Coco is a charming yellow-and-white Cockatiel who whistles sweet melodies and loves sitting on shoulders during quiet evenings.', '/images/hero.jpg', 'Available', 'San Jose Adoption Hub');

INSERT INTO adoptions (pet_id, applicant_name, email, phone, housing_type, has_yard, other_pets, experience, status, notes) VALUES
(4, 'Sarah Jenkins', 'sarah.j@example.com', '(555) 234-5678', 'Apartment', 0, '1 senior cat', 'Had dogs growing up for 10+ years.', 'Under Review', 'Application looks promising, landlord approval confirmed.'),
(1, 'Michael Chen', 'mchen@example.com', '(555) 876-5432', 'House', 1, 'None', 'First time dog owner, works from home.', 'Submitted', 'Scheduled initial phone interview.');
