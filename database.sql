-- Enhanced Library Management System Database
-- Aligned with the improved Java application

-- Create Database
CREATE DATABASE EnhancedLibraryManagement;
USE EnhancedLibraryManagement;

-- 1. Categories Table
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Publishers Table  
CREATE TABLE publishers (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    address TEXT,
    contact VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 3. Books Table (Enhanced with proper relationships)
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(150) NOT NULL,
    genre VARCHAR(100),
    isbn VARCHAR(20) UNIQUE NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    category_id INT NOT NULL,
    publisher_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 4. Admin Users Table (Enhanced with better security considerations)
CREATE TABLE admin_users (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL, -- In production, this should be hashed
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 5. Audit Log Table (Optional - for tracking changes)
CREATE TABLE audit_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50) NOT NULL,
    operation VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    record_id INT NOT NULL,
    old_values JSON,
    new_values JSON,
    admin_id INT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admin_users(admin_id)
);

-- Insert Initial Data

-- Insert Categories (matching Java application)
INSERT INTO categories (category_name, description) VALUES
('Science', 'Books related to scientific topics'),
('Technology', 'Books about technology and programming'),
('Literature', 'Fiction and literature books'),
('History', 'Historical books and documentaries'),
('Mathematics', 'Books related to mathematical concepts'),
('Arts', 'Books about arts, music, and creative subjects');

-- Insert Publishers (matching Java application)
INSERT INTO publishers (name, address, contact) VALUES
('Tech Publications', '123 Tech Street', 'tech@pub.com'),
('Science Press', '456 Science Ave', 'info@scipress.com'),
('Academic Press', '789 Academic Blvd', 'contact@academic.com'),
('Literary House', '321 Literature Lane', 'books@litehouse.com');

-- Insert Initial Books (matching Java application with proper IDs)
INSERT INTO books (title, author, genre, isbn, category_id, publisher_id) VALUES
('Ancient Civilizations', 'Balgurusaami', 'History', '978-1-234567-89-0', 4, 2),
('Java Programming', 'Balgurusaami', 'Technology', '978-1-234567-90-6', 2, 1),
('Data Structures', 'John Smith', 'Technology', '978-1-234567-91-3', 2, 1),
('Advanced Mathematics', 'Dr. Sarah Wilson', 'Mathematics', '978-1-234567-92-0', 5, 3),
('Modern Physics', 'Prof. Michael Brown', 'Science', '978-1-234567-93-7', 1, 2);

-- Insert Admin Users (In production, passwords should be hashed)
INSERT INTO admin_users (username, password, is_active) VALUES
('admin', 'password', TRUE),
('librarian', 'lib123', TRUE);

-- ===== ENHANCED QUERIES FOR LIBRARY OPERATIONS =====

-- 1. View all books with complete relationship details
SELECT 
    b.book_id,
    b.title,
    b.author,
    b.genre,
    b.isbn,
    CASE WHEN b.is_available THEN 'Available' ELSE 'Not Available' END AS availability_status,
    c.category_name,
    c.description AS category_description,
    p.name AS publisher_name,
    p.contact AS publisher_contact,
    b.created_at AS date_added
FROM books b
INNER JOIN categories c ON b.category_id = c.category_id
INNER JOIN publishers p ON b.publisher_id = p.publisher_id
ORDER BY b.book_id;

-- 2. Search books by multiple criteria (title, author, genre, ISBN)
-- Example: Search for books containing 'Java' or 'Technology'
SELECT 
    b.book_id,
    b.title,
    b.author,
    b.genre,
    b.isbn,
    c.category_name,
    p.name AS publisher_name
FROM books b
INNER JOIN categories c ON b.category_id = c.category_id
INNER JOIN publishers p ON b.publisher_id = p.publisher_id
WHERE b.title LIKE '%Java%' 
   OR b.author LIKE '%Smith%' 
   OR b.genre LIKE '%Technology%'
   OR b.isbn LIKE '%234567%'
ORDER BY b.title;

-- 3. Enhanced library statistics
SELECT 
    COUNT(*) as total_books,
    SUM(CASE WHEN is_available = TRUE THEN 1 ELSE 0 END) as available_books,
    SUM(CASE WHEN is_available = FALSE THEN 1 ELSE 0 END) as borrowed_books,
    COUNT(DISTINCT category_id) as total_categories,
    COUNT(DISTINCT publisher_id) as total_publishers
FROM books;

-- 4. Statistics by category
SELECT 
    c.category_name,
    COUNT(b.book_id) as total_books,
    SUM(CASE WHEN b.is_available THEN 1 ELSE 0 END) as available_books,
    SUM(CASE WHEN NOT b.is_available THEN 1 ELSE 0 END) as borrowed_books
FROM categories c
LEFT JOIN books b ON c.category_id = b.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_books DESC;

-- 5. Statistics by publisher
SELECT 
    p.name as publisher_name,
    COUNT(b.book_id) as total_books,
    SUM(CASE WHEN b.is_available THEN 1 ELSE 0 END) as available_books,
    SUM(CASE WHEN NOT b.is_available THEN 1 ELSE 0 END) as borrowed_books
FROM publishers p
LEFT JOIN books b ON p.publisher_id = b.publisher_id
GROUP BY p.publisher_id, p.name
ORDER BY total_books DESC;

-- ===== CRUD OPERATIONS =====

-- BOOK OPERATIONS

-- Add new book (with proper category and publisher validation)
INSERT INTO books (title, author, genre, isbn, category_id, publisher_id) 
SELECT 'New Book Title', 'Author Name', 'Genre', '978-1-234567-94-4', 1, 1
WHERE EXISTS (SELECT 1 FROM categories WHERE category_id = 1)
  AND EXISTS (SELECT 1 FROM publishers WHERE publisher_id = 1);

-- Find book by ISBN (used in Java application)
SELECT * FROM books WHERE isbn = '978-1-234567-90-6';

-- Find book by ID (used in Java application)
SELECT * FROM books WHERE book_id = 1;

-- Update book availability by ISBN
UPDATE books 
SET is_available = FALSE, updated_at = CURRENT_TIMESTAMP 
WHERE isbn = '978-1-234567-90-6';

-- Update book availability by ID
UPDATE books 
SET is_available = TRUE, updated_at = CURRENT_TIMESTAMP 
WHERE book_id = 1;

-- Remove book by ISBN (with safety check)
DELETE FROM books WHERE isbn = '978-1-234567-94-4';

-- Remove book by ID (with safety check)
DELETE FROM books WHERE book_id = 6;

-- CATEGORY OPERATIONS

-- View all categories
SELECT * FROM categories ORDER BY category_name;

-- Add new category
INSERT INTO categories (category_name, description) 
VALUES ('Philosophy', 'Books related to philosophical thoughts and ideas');

-- Find category by ID
SELECT * FROM categories WHERE category_id = 1;

-- Remove category (only if no books are associated)
DELETE FROM categories 
WHERE category_id = 6 
AND NOT EXISTS (SELECT 1 FROM books WHERE category_id = 6);

-- PUBLISHER OPERATIONS

-- View all publishers
SELECT * FROM publishers ORDER BY name;

-- Add new publisher
INSERT INTO publishers (name, address, contact) 
VALUES ('Digital Press', '555 Digital Ave', 'info@digitalpress.com');

-- Find publisher by ID
SELECT * FROM publishers WHERE publisher_id = 1;

-- Remove publisher (only if no books are associated)
DELETE FROM publishers 
WHERE publisher_id = 5 
AND NOT EXISTS (SELECT 1 FROM books WHERE publisher_id = 5);

-- ADMIN USER OPERATIONS

-- Admin login verification
SELECT admin_id, username, is_active, last_login 
FROM admin_users 
WHERE username = 'admin' AND password = 'password' AND is_active = TRUE;

-- Update last login timestamp
UPDATE admin_users 
SET last_login = CURRENT_TIMESTAMP 
WHERE username = 'admin';

-- ===== ADVANCED QUERIES =====

-- Books that need attention (not available for long time)
SELECT 
    b.book_id,
    b.title,
    b.author,
    c.category_name,
    b.updated_at as last_status_change
FROM books b
INNER JOIN categories c ON b.category_id = c.category_id
WHERE b.is_available = FALSE 
AND b.updated_at < DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY b.updated_at;

-- Most popular categories (by book count)
SELECT 
    c.category_name,
    COUNT(b.book_id) as book_count,
    ROUND((COUNT(b.book_id) * 100.0 / (SELECT COUNT(*) FROM books)), 2) as percentage
FROM categories c
INNER JOIN books b ON c.category_id = b.category_id
GROUP BY c.category_id, c.category_name
ORDER BY book_count DESC;

-- Publishers with their book distribution
SELECT 
    p.name as publisher_name,
    p.contact,
    COUNT(b.book_id) as total_books,
    GROUP_CONCAT(DISTINCT c.category_name ORDER BY c.category_name) as categories_published
FROM publishers p
INNER JOIN books b ON p.publisher_id = b.publisher_id
INNER JOIN categories c ON b.category_id = c.category_id
GROUP BY p.publisher_id, p.name, p.contact
ORDER BY total_books DESC;

-- Books by author with category distribution
SELECT 
    b.author,
    COUNT(b.book_id) as total_books,
    GROUP_CONCAT(DISTINCT c.category_name ORDER BY c.category_name) as categories_written,
    SUM(CASE WHEN b.is_available THEN 1 ELSE 0 END) as available_books
FROM books b
INNER JOIN categories c ON b.category_id = c.category_id
GROUP BY b.author
ORDER BY total_books DESC;

-- ===== VIEWS FOR COMMON OPERATIONS =====

-- Create view for book details with relationships
CREATE VIEW book_details AS
SELECT 
    b.book_id,
    b.title,
    b.author,
    b.genre,
    b.isbn,
    b.is_available,
    c.category_name,
    c.description as category_description,
    p.name as publisher_name,
    p.address as publisher_address,
    p.contact as publisher_contact,
    b.created_at,
    b.updated_at
FROM books b
INNER JOIN categories c ON b.category_id = c.category_id
INNER JOIN publishers p ON b.publisher_id = p.publisher_id;

-- Create view for library summary
CREATE VIEW library_summary AS
SELECT 
    (SELECT COUNT(*) FROM books) as total_books,
    (SELECT COUNT(*) FROM books WHERE is_available = TRUE) as available_books,
    (SELECT COUNT(*) FROM books WHERE is_available = FALSE) as borrowed_books,
    (SELECT COUNT(*) FROM categories) as total_categories,
    (SELECT COUNT(*) FROM publishers) as total_publishers,
    (SELECT COUNT(*) FROM admin_users WHERE is_active = TRUE) as active_admins;

-- ===== INDEXES FOR PERFORMANCE =====

-- Create indexes for better performance
CREATE INDEX idx_books_isbn ON books(isbn);
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_author ON books(author);
CREATE INDEX idx_books_category ON books(category_id);
CREATE INDEX idx_books_publisher ON books(publisher_id);
CREATE INDEX idx_books_availability ON books(is_available);
CREATE INDEX idx_categories_name ON categories(category_name);
CREATE INDEX idx_publishers_name ON publishers(name);

-- ===== SAMPLE USAGE OF VIEWS =====

-- Use the book_details view for comprehensive book listing
SELECT * FROM book_details WHERE is_available = TRUE ORDER BY title;

-- Use the library_summary view for dashboard
SELECT * FROM library_summary;

-- ===== DATA INTEGRITY CONSTRAINTS =====

-- Add check constraints for data validation
ALTER TABLE books 
ADD CONSTRAINT chk_isbn_format 
CHECK (isbn REGEXP '^[0-9]{3}-[0-9]{1}-[0-9]{6}-[0-9]{2}-[0-9]{1}$');

-- Add constraint for non-empty titles
ALTER TABLE books 
ADD CONSTRAINT chk_title_not_empty 
CHECK (TRIM(title) != '');

-- Add constraint for non-empty author names
ALTER TABLE books 
ADD CONSTRAINT chk_author_not_empty 
CHECK (TRIM(author) != '');