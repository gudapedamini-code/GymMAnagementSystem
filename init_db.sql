-- Initialize databases and tables for Gym Management System

-- 1. Manage Database (Users / Authentication)
CREATE DATABASE IF NOT EXISTS manage;
USE manage;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    uname VARCHAR(100) NOT NULL,
    upwd VARCHAR(100) NOT NULL
);

INSERT INTO users (uname, upwd) VALUES 
('admin', 'admin123'),
('root', 'Vedant@123')
ON DUPLICATE KEY UPDATE upwd=VALUES(upwd);


-- 2. MyDB Database (Members Data)
CREATE DATABASE IF NOT EXISTS mydb;
USE mydb;

CREATE TABLE IF NOT EXISTS data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    lastname VARCHAR(100),
    age VARCHAR(10),
    gender VARCHAR(20),
    dob VARCHAR(50),
    email VARCHAR(100),
    contact VARCHAR(50),
    addres VARCHAR(255),
    height VARCHAR(20),
    weight VARCHAR(20),
    membership VARCHAR(50),
    image VARCHAR(255)
);

INSERT INTO data (name, lastname, age, gender, dob, email, contact, addres, height, weight, membership, image) 
VALUES ('John', 'Doe', '25', 'Male', '1999-01-01', 'john@example.com', '9876543210', 'Main Street', '175', '70', '1 Year', '')
ON DUPLICATE KEY UPDATE name=VALUES(name);


-- 3. Payment Database (Payments / Fees)
CREATE DATABASE IF NOT EXISTS payment;
USE payment;

CREATE TABLE IF NOT EXISTS pay (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    lname VARCHAR(100),
    month VARCHAR(50),
    amount VARCHAR(50)
);

INSERT INTO pay (name, lname, month, amount)
VALUES ('John', 'Doe', 'January', '5000')
ON DUPLICATE KEY UPDATE name=VALUES(name);


-- 4. VB Database
CREATE DATABASE IF NOT EXISTS vb;
USE vb;

CREATE TABLE IF NOT EXISTS data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    info VARCHAR(255)
);

