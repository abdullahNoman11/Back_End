CREATE DATABASE salon;

USE salon;

CREATE TABLE users (
	id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	password VARCHAR(128) NOT NULL,
	name VARCHAR(50) NOT NULL, 
	email VARCHAR(50) NOT NULL UNIQUE, 
	contact VARCHAR(15) NULL,
	gender ENUM('Male', 'Female', 'Other') DEFAULT 'Female'
);

INSERT INTO users (name, email, password, gender) VALUE ('Arose Niazi' ,'niazi.arose@gmail.com', '$2b$04$k6VYbTEHfWP8/wA.TfeTqO6yIYMY6tqjz31uL1BlJBJzeadE21AOK', 'Male');

CREATE TABLE owners (
	id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	password VARCHAR(128) NOT NULL,
	name VARCHAR(50) NOT NULL, 
	email VARCHAR(50) NOT NULL UNIQUE, 
	contact VARCHAR(15) NULL,
	city VARCHAR(30) NULL
);

INSERT INTO owners (name, email, password, city) VALUE ('Arose Niazi' ,'niazi.arose@gmail.com', '$2b$04$k6VYbTEHfWP8/wA.TfeTqO6yIYMY6tqjz31uL1BlJBJzeadE21AOK', 'Lahore');

CREATE TABLE salons (
	id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(50) NOT NULL, 
	description VARCHAR(512) NULL,
	contact VARCHAR(128) NOT NULL, 
	city VARCHAR(30) NOT NULL,
	address VARCHAR(128) NOT NULL,
	price ENUM('Low', 'Medium', 'High') DEFAULT 'Medium',
	image VARCHAR(128) NULL,
	services JSON,
	active INT(1) DEFAULT 1,
	owner INT UNSIGNED NOT NULL,
	FOREIGN KEY (owner) REFERENCES owners(id) ON UPDATE CASCADE ON DELETE CASCADE
);

INSERT INTO salons (name, description, contact, city, address, services, owner) VALUE ('Meraki Beauty Wellness', 'Welcome to Meraki Salon Askari 11. We are here to offer you best beauty services like manicures, pedicures, hairstyles, hair colors, makeup, mehndi, or facials at a reasonable price. Schedule your appointment now and have a great time', '0304-9999304', 'Lahore', 'FC3P+4VF, Askari 11 Sector B, Lahore, Punjab', '[{"name":"Microdermabrasion","price":300},{"name":"Ficial","price":2000}]', 1);

CREATE TABLE offers (
	code VARCHAR(30) PRIMARY KEY,
	image VARCHAR(128) NULL,
	amount FLOAT UNSIGNED NOT NULL,
	active INT(1) DEFAULT 1,
	salon INT UNSIGNED NOT NULL,
	FOREIGN KEY (salon) REFERENCES salons(id) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE bookings (
	id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
	services JSON,
	status ENUM('Pending', 'Confirmed', 'Completed', 'Cancelled'),
	offer VARCHAR(30) NULL,
	salon INT UNSIGNED NOT NULL,
	user INT UNSIGNED NOT NULL,
	FOREIGN KEY (offer) REFERENCES offers(code) ON UPDATE CASCADE,
	FOREIGN KEY (salon) REFERENCES salons(id) ON UPDATE CASCADE,
	FOREIGN KEY (user) REFERENCES users(id) ON UPDATE CASCADE
);

CREATE TABLE ratings (
	id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
	salon INT UNSIGNED NOT NULL,
	user INT UNSIGNED NOT NULL,
	rating INT(1) DEFAULT 1,
	UNIQUE(salon,user),
	FOREIGN KEY (salon) REFERENCES salons(id) ON UPDATE CASCADE,
	FOREIGN KEY (user) REFERENCES users(id) ON UPDATE CASCADE
);

CREATE VIEW salon_details AS (
	SELECT 
		s.*, 
		IFNULL(r.rating,0) AS rating, 
		IFNULL(r.count,0) AS count 
	FROM salons AS s 
	LEFT JOIN (
		SELECT 
			AVG(rating) AS rating, 
			COUNT(id) AS count, 
		salon FROM ratings 
		GROUP BY salon
	) AS r ON r.salon = s.id
);

CREATE VIEW booking_details AS (
	SELECT 
		b.*,user_name,salon_name
	FROM bookings AS b 
	INNER JOIN (
		SELECT 
			id AS user,
			name AS user_name
		FROM users 
	) AS u ON u.user = b.user
	INNER JOIN (
		SELECT 
			id AS salon,
			name AS salon_name
		FROM salons 
	) AS s ON s.salon = b.salon
);