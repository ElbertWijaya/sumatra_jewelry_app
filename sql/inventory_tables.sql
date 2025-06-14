-- Tabel utama inventory
CREATE TABLE inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    jewelry_type VARCHAR(50) NOT NULL,
    gold_color VARCHAR(30) NOT NULL,
    gold_type VARCHAR(20) NOT NULL,
    ring_size VARCHAR(10),
    items_price DECIMAL(18,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- imagePaths bisa disimpan di tabel terpisah atau JSON/text
    image_paths TEXT NOT NULL
);

-- Tabel batu yang digunakan (relasi ke inventory)
CREATE TABLE inventory_stone_used (
    id INT AUTO_INCREMENT PRIMARY KEY,
    inventory_id INT NOT NULL,
    stone_type VARCHAR(50) NOT NULL,
    stone_qty INT NOT NULL,
    stone_size VARCHAR(20) NOT NULL,
    FOREIGN KEY (inventory_id) REFERENCES inventory(id) ON DELETE CASCADE
);
