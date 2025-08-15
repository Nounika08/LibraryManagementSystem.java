-- Library Management System Database
-- Simple SQL setup without complex operations

-- Create Database
CREATE DATABASE LibraryManagement;
USE LibraryManagement;

-- 1. Categories Table
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    description TEXT
);

-- 2. Publishers Table  
CREATE TABLE publishers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    address TEXT,
    contact VARCHAR(100)
);

-- 3. Books Table
CREATE TABLE books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(150) NOT NULL,
    genre VARCHAR(100),
    isbn VARCHAR(20) UNIQUE,
    is_available BOOLEAN DEFAULT TRUE,
    category_id INT,
    publisher_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (publisher_id) REFERENCES publishers(id)
);

-- 4. Admin Users Table (Optional)
CREATE TABLE admin_users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL
);

-- Insert Initial Data

-- Insert Categories
INSERT INTO categories (category_name, description) VALUES
('Science', 'Books related to scientific topics'),
('Technology', 'Books about technology and programming'),
('Literature', 'Fiction and literature books'),
('History', 'Historical books and documentaries');

-- Insert Publishers
INSERT INTO publishers (name, address, contact) VALUES
('Tech Publications', '123 Tech Street', 'tech@pub.com'),
('Science Press', '456 Science Ave', 'info@scipress.com');

-- Insert Initial Books
INSERT INTO books (title, author, genre, isbn, category_id, publisher_id) VALUES
('Ancient Civilizations', 'Balgurusaami', 'History', '978-1-234567-89-0', 4, 2),
('Java Programming', 'Balgurusaami', 'Technology', '978-1-234567-90-6', 2, 1),
('Data Structures', 'John Smith', 'Technology', '978-1-234567-91-3', 2, 1);

-- Insert Admin User
INSERT INTO admin_users (username, password) VALUES
('admin', 'password');

-- Basic Queries for Library Operations

-- View all books with category and publisher info
SELECT 
    b.id,
    b.title,
    b.author,
    b.genre,
    b.isbn,
    b.is_available,
    c.category_name,
    p.name as publisher_name
FROM books b
LEFT JOIN categories c ON b.category_id = c.id
LEFT JOIN publishers p ON b.publisher_id = p.id;

-- Search books by title, author, or genre
SELECT * FROM books 
WHERE title LIKE '%Java%' 
   OR author LIKE '%Smith%' 
   OR genre LIKE '%Technology%';

-- Get library statistics
SELECT 
    COUNT(*) as total_books,
    SUM(CASE WHEN is_available = TRUE THEN 1 ELSE 0 END) as available_books,
    SUM(CASE WHEN is_available = FALSE THEN 1 ELSE 0 END) as borrowed_books
FROM books;

-- Get books by category
SELECT b.*, c.category_name 
FROM books b 
JOIN categories c ON b.category_id = c.id 
WHERE c.category_name = 'Technology';

-- Update book availability
UPDATE books SET is_available = FALSE WHERE id = 1;

-- Add new book
INSERT INTO books (title, author, genre, isbn, category_id, publisher_id) 
VALUES ('New Book Title', 'Author Name', 'Genre', '978-1-234567-92-0', 1, 1);

-- Remove book
DELETE FROM books WHERE id = 4;

-- View all categories
SELECT * FROM categories;

-- View all publishers
SELECT * FROM publishers;

-- Add new category
INSERT INTO categories (category_name, description) 
VALUES ('Mathematics', 'Books related to mathematical concepts');

-- Add new publisher
INSERT INTO publishers (name, address, contact) 
VALUES ('Academic Press', '789 Academic Blvd', 'contact@academic.com');

-- Admin login verification
SELECT * FROM admin_users WHERE username = 'admin' AND password = 'password';